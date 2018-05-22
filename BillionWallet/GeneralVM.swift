//
//  GeneralVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol GeneralVMDelegate: class {
    func willUpdateItems(_ items: HistoryUpdater)
    func didReceiveContacts()
    func didChangeLockStatus(_ isLocked: Bool)
    func didChangeIsTouchIdEnabled(_ isTouchIdEnabled: Bool)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func didSelectContact(_ contact: ContactProtocol)
    func setConveyorAfterUnlock()
}

class GeneralVM {
    enum SyncStatus: String {
        case connecting
        case syncing
        case synced
    }
    
    lazy var txsDataManager: TxsDataManager = {
        let manager = TxsDataManager(viewModel: self, fiatConverter: fiatConverter)
        return manager
    }()
    
    lazy var contactsDataSource: GeneralContactsDataSource = {
        let dataSource = GeneralContactsDataSource(viewModel: self)
        dataSource.delegate = self
        return dataSource
    }()
    var currentFilter: FilterView.Filter?
    
    var contacts = [ContactProtocol]() {
        didSet {
            delegate?.didReceiveContacts()
        }
    }
    
    var filteredItems = [HistoryDisplayable]()
    
    var passcode: String? {
        return keychain.pin
    }
    
    var isLocked: Bool {
        return keychain.isLocked
    }
    
    var isTouchIdEnabled: Bool {
        return defaultsProvider.isTouchIdEnabled
    }
    
    var batchUpdateQueue: DispatchQueue
    
    weak var delegate: GeneralVMDelegate?
    weak var cellDelegate: TxCellDelegate?
    
    private var messageFetchProvider: MessageFetchProviderProtocol!
    weak var walletProvider: WalletProvider!
    weak var accountProvider: AccountManager?
    weak var icloudProvider: ICloud!
    weak var defaultsProvider: Defaults!
    weak var contactsProvider: ContactsProvider!
    private let ratesProvider: RateProviderProtocol!
    weak var userPaymentRequestProvider: UserPaymentRequestProtocol!
    weak var selfPaymentRequestProvider: SelfPaymentRequestProtocol!
    weak var failureTransactionProvider: FailureTxProtocol!
    weak var feeProvider: FeeProvider?
    weak var tapticService: TapticService!
    private let authChecker: AuthCheckerProtocol
    var keychain: Keychain
    var imageCache = NSCache<NSString,UIImage>()
    private let routingVisitor: HistoryDisplayableVisitor
    private let fiatConverter: FiatConverter
    private var contactChannel: ContactChannel?
    private var transactionsInterim: [Transaction] = []
    private var sortedTxs: [Transaction] = []
    
    // MARK: - Lifecycle
    init(walletProvider: WalletProvider,
         keychain: Keychain,
         accountProvider: AccountManager,
         icloudProvider: ICloud,
         defaultsProvider: Defaults,
         contactsProvider: ContactsProvider,
         ratesProvider: RateProviderProtocol,
         feeProvider: FeeProvider,
         userPaymentRequestProvider: UserPaymentRequestProtocol,
         selfPaymentRequestProvider: SelfPaymentRequestProtocol,
         failureTransactionProvider: FailureTxProtocol,
         routingVisitor: HistoryDisplayableVisitor,
         tapticService: TapticService,
         messageFetchProvider: MessageFetchProviderProtocol,
         fiatConverter: FiatConverter,
         authChecker: AuthCheckerProtocol) {
        
        self.messageFetchProvider = messageFetchProvider
        self.routingVisitor = routingVisitor
        self.walletProvider = walletProvider
        self.accountProvider = accountProvider
        self.icloudProvider = icloudProvider
        self.defaultsProvider = defaultsProvider
        self.ratesProvider = ratesProvider
        self.contactsProvider = contactsProvider
        self.feeProvider = feeProvider
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
        self.failureTransactionProvider = failureTransactionProvider
        self.tapticService = tapticService
        self.keychain = keychain
        self.fiatConverter = fiatConverter
        self.authChecker = authChecker
        
        self.batchUpdateQueue = DispatchQueue(label: "batch-update-queue")
        walletProvider.peerManager.connect()
        feeProvider.startTimer()
        messageFetchProvider.startFetching()
        copyPrivPcToSharedKeychain()
        
        let clearCacheForContact = "ClearCacheForContactNotification"
        let txStatusNotify = Notification.Name(rawValue: "BRPeerManagerTxStatusNotification")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateHistory),
                                               name: UserPaymentRequestEvent,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHistory),
                                               name: SelfPaymentRequestEvent,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHistory),
                                               name: FailureTransactionsEvent,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAll),
                                               name: .walletBalanceChangedNotificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateItemsForRates(_:)),
                                               name: .walletRatesChangedNotificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLockStatus(_:)),
                                               name: .didUpdateLockStatus,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearCacheForContact(notification:)),
                                               name: NSNotification.Name(rawValue: clearCacheForContact),
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHistory),
                                               name: .transactionsLinkedToContact,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateHistory),
                                               name: txStatusNotify,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAll),
                                               name: .walletSwitchCurrencyNotificationName,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.contactChannel?.removeObserver(withId: self.objId)
        self.contactChannel = nil
    }
  
    func copyPrivPcToSharedKeychain() {
        let selfPrivData = accountProvider?.getSelfCPPriv()
        let keychain = Keychain()
        keychain.selfPCPriv = selfPrivData
    }
    
    func isNeedToCreatePin() -> Bool {
        return (passcode ?? "").isEmpty
    }
    
    @objc func clearCacheForContact(notification: Notification) {
        if let userInfo = notification.userInfo, let cache = userInfo["cacheString"] as? NSString {
            imageCache.removeObject(forKey: cache)
        }
    }
    
    @objc func didChangeIsTouchIdEnabled(_ notification: Notification) {
        if let isTouchIdEnabled = notification.object as? Bool {
            delegate?.didChangeIsTouchIdEnabled(isTouchIdEnabled)
        }
    }
    
    func updateFiatConverter() {
        self.fiatConverter.changeCurrency(newCurrency: defaultsProvider.currencies.first!)
    }
    
    @objc func updateAll() {
        updateFiatConverter()
        updateHistory(nil)
    }
    
    @objc func didUpdateLockStatus(_ notification: Notification) {
        if let isLocked = notification.object as? Bool {
            delegate?.didChangeLockStatus(isLocked)
        }
    }
    
    @objc func updateItemsForRates(_ notification: Notification) {
        if let rateHistory = notification.object as? RateHistory {
            var updateIndexes:IndexSet = []
            let newItems = NSArray(array: self.filteredItems, copyItems: true) as! [HistoryDisplayable]
            for (i, var element) in newItems.enumerated() {
                if Int64(element.time.timeIntervalSince1970) == rateHistory.blockTimestamp {
                    if element is TransactionDisplayer {
                        guard let currency = self.defaultsProvider.currencies.first else { return }
                        let rateSource = HistoricalRatesSource(ratesProvider: self.ratesProvider)
                        rateSource.set(time: element.time.timeIntervalSince1970)
                        let historicalFiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
                        let txHashHex = element.identity.components(separatedBy: ":").last
                        let txs = transactionsInterim.filter { $0.txHash.data.hex == txHashHex }
                        if let tx = txs.first {
                            element = TransactionDisplayer(transaction: tx,
                                                           walletProvider: self.walletProvider,
                                                           defaults: self.defaultsProvider,
                                                           fiatConverter: self.fiatConverter,
                                                           historicalFiatConverter: historicalFiatConverter)
                            updateIndexes.insert(i)
                        }
                    }
                }
            }
            if updateIndexes.count > 0 {
                
                Logger.debug("INDEXES COUNT FOR UPDATE RATES: \(updateIndexes.count)")
                let updater = HistoryUpdater()
                updater.configureUpdateByIndexes(indexes: updateIndexes)
                
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.willUpdateItems(updater)
                }
            }
        }
    }
    
    func compareHistoryDisplayable(_ lhs: HistoryDisplayable, _ rhs: HistoryDisplayable) -> Bool {
        if lhs.time > rhs.time {
            return true
        } else if lhs.time == rhs.time && lhs.sortPriority > rhs.sortPriority {
            return true
        } else if lhs.time == rhs.time && lhs.sortPriority == rhs.sortPriority {
            return lhs.identity.data(using: .utf8)!.last! > rhs.identity.data(using: .utf8)!.last!
        } else {
            return false
        }
    }
    
    @objc func updateHistory(_ notification: Notification?) {
        Logger.debug("\(String(describing: notification))")
        batchUpdateQueue.async {
            guard let wallet = try? self.walletProvider.getWallet() else {
                return
            }
            
            // Memorize old state
            let oldItems = self.filteredItems
            
            
            // Compute new state
            let bTransactions = wallet.allTransactions
            
            let contacts = self.contactsProvider.allContacts()
            
            self.transactionsInterim.removeAll()
            self.sortedTxs.removeAll()
            self.transactionsInterim = bTransactions.map { transaction -> Transaction in
                let tx = Transaction(brTransaction: transaction, walletProvider: self.walletProvider)
                let txHash = UInt256S(transaction.txHash)
                
                if let contact = self.getContact(txHash: txHash, contacts: contacts) {
                    let isNotificationTx = (contact as? PaymentCodeContact)?.isContactForNotificationTransaction(txHash: txHash)
                    tx.contact = contact
                    tx.isNotificationTx = isNotificationTx == true
                }
                
                return tx
            }
            
            for tx in self.transactionsInterim {
                if !tx.isIncomingNotificationTx() {
                    self.sortedTxs.append(tx)
                }
            }
            
            var newTxs = [TransactionDisplayer]()
            for tx in self.sortedTxs {
                autoreleasepool(invoking: {
                    guard let currency = self.defaultsProvider.currencies.first else { return }
                    let rateSource = HistoricalRatesSource(ratesProvider: self.ratesProvider)
                    rateSource.set(time: tx.dateTimestamp.timeIntervalSince1970)
                    let historicalFiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
                    newTxs.append(TransactionDisplayer(transaction: tx,
                                                       walletProvider: self.walletProvider,
                                                       defaults: self.defaultsProvider,
                                                       fiatConverter: self.fiatConverter,
                                                       historicalFiatConverter: historicalFiatConverter))
                })
            }
            
            let userPaymentRequests = self.userPaymentRequestProvider.allUserPaymentRequests.filter {
                $0.state == .waiting || $0.state == .declined || $0.state == .failed
            }
            let uprDisplayers = userPaymentRequests.map { UserPaymentRequestDisplayer(userPaymentRequest: $0, fiatConverter: self.fiatConverter, contactsProvider: self.contactsProvider) }
            
            let selfPaymentRequests = self.selfPaymentRequestProvider.allSelfPaymentRequests
            let sprDisplayers = selfPaymentRequests.map { SelfPaymentRequestDisplayer(selfPaymentRequest: $0, contactsProvider: self.contactsProvider, fiatConverter: self.fiatConverter) }
            
            let failureTransactions = self.failureTransactionProvider.allFailureTxs
            let failureTxDisplayers = failureTransactions.map { FailureTxDisplayer(failureTx: $0, fiatConverter: self.fiatConverter, contactsProvider: self.contactsProvider) }
            
            let historyItems = Array([
                newTxs as [HistoryDisplayable],
                uprDisplayers as [HistoryDisplayable],
                failureTxDisplayers as [HistoryDisplayable],
                sprDisplayers as [HistoryDisplayable]
                ].joined())
            let newItems = historyItems.sorted(by: self.compareHistoryDisplayable)
            
            // Create Update object
            let updater = HistoryUpdater()
            updater.configureUpdate(fromState: oldItems, toState: newItems)
            // Call delegate's method with update object
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.willUpdateItems(updater)
            }
        }
    }
    
    func commitUpdates(_ updates: HistoryUpdater) throws {
        // FIXME: Assert old state is equal to current state
        guard filteredItems.count == updates.oldState.count else {
            Logger.warn("Updater startState does not match current state: \(filteredItems.count) != \(updates.oldState.count)")
            self.updateHistory(nil)
            throw GeneralVMError.commitCheckFailed
        }
        // Change current state to updated values
        self.filteredItems = updates.newState
    }
    
    func itemForIdentity(_ identity: String) -> HistoryDisplayable {
        // FIXME: thread safety
        return filteredItems.first { $0.identity == identity }!
    }
    
    private func getContact(txHash: UInt256S, contacts: [ContactProtocol]) -> ContactProtocol? {
        if let firstContact = contacts.first(where: { $0.txHashes.contains(txHash.data.hex) }) {
            if firstContact.isArchived,
                let firstUnarchivedContact = contacts.first(where: { $0.txHashes.contains(txHash.data.hex) && !$0.isArchived }) {
                return firstUnarchivedContact
            }
            return firstContact
        }
        return nil
    }
    
    func getContacts() {
        contacts = contactsProvider.allContacts(isArchived: false)
    }
    
    func restoreIfNeeded() {
        let digest = accountProvider?.getOrCreateWalletDigest()!
        restoreFromIcloudBackupIfNeeded(digest: digest!)
    }
    
    func restoreFromIcloudBackupIfNeeded(digest: String) {
        if !defaultsProvider.isBackupRestored && !defaultsProvider.isWalletJustCreated {
            icloudProvider?.restoreComments(walletProvider: walletProvider)
            icloudProvider?.restoreConfig(walletProvider: walletProvider, defaults: defaultsProvider, currentWalletDigest: digest)
            icloudProvider?.restoreContacts(contactsProvider: contactsProvider)
            authChecker.ensureAuthIsOk()
        }
    }
    
    func showDetails(for historyDisplayable: HistoryDisplayable, cellY: CGFloat, backImage: UIImage) {
        historyDisplayable.showDetails(visitor: routingVisitor, cellY: cellY, backImage: backImage)
    }
    
    // MARK: - Channels
    private lazy var objId: String = {
        let id = "\(type(of: self)):\(String(format: "%p", unsafeBitCast(self, to: Int.self)))"
        return id
    }()
    
    func setContactChannel(_ channel: ContactChannel) {
        self.contactChannel = channel
        channel.addObserver(Observer<ContactsProvider.ContactMessage>(id: self.objId, callback: { [weak self] message in
            self?.acceptContactMessage(message)
        }))
    }
    
    private func acceptContactMessage(_ message: ContactsProvider.ContactMessage) {
        switch message {
        case .contactAdded(let newContact):
            if !self.contacts.contains(where: { $0.uniqueValue == newContact.uniqueValue }) {
                self.contacts.append(newContact)
            }
        case .contactUpdated:
            return
        case .contactRemoved(let removedContact):
            if let index = self.contacts.index(where: { $0.uniqueValue == removedContact.uniqueValue }) {
                self.contacts.remove(at: index)
            }
        }
    }
}

// MARK: - PasscodeOutputDelegate

extension GeneralVM: PasscodeOutputDelegate {
    
    func didCompleteVerification() {
        delegate?.setConveyorAfterUnlock()
    }
    
    func didUpdatePasscode(_ passcode: String) {
        keychain.pin = passcode
        didCompleteVerification()
    }
    
    func didCancelVerification() {
        delegate?.setConveyorAfterUnlock()
    }
}

// MARK: - FilterViewDelegate
extension GeneralVM: FilterViewDelegate {
    
    func didAddFilter(_ filter: FilterView.Filter) {
        currentFilter = filter
    }
    
    func didRemoveFilters() {
    }
}

// MARK: - GeneralContactsDataSourceDelegate

extension GeneralVM: GeneralContactsDataSourceDelegate {
    
    func didSelect(at index: Int) {
        let contact = contacts[index]
        delegate?.didSelectContact(contact)
    }
}

enum GeneralVMError: LocalizedError {
    case commitCheckFailed
    
    // TODO: Localize?
    var errorDescription: String? {
        switch self {
        case .commitCheckFailed:
            return "Updater old state does not match current state"
        }
    }
}
