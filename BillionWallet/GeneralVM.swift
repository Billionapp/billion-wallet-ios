//
//  GeneralVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol GeneralVMDelegate: class {
    func balanceDidChange(number: UInt64)
    func didReceiveTransactions()
    func didSelectFilter(_ value: Bool)
    func reachabilityDidChange(status: Bool)
    func didChangeLockStatus(_ isLocked: Bool)
    func didChangeIsTouchIdEnabled(_ isTouchIdEnabled: Bool)
}

class GeneralVM {
    
    enum SyncStatus: String {
        case connecting
        case syncing
        case synced
    }

    var dateFormatter: DateFormatter!
    var currentFilter: FilterView.Filter?
    var filteredTransactions = [Transaction]() {
        didSet {
            delegate?.didReceiveTransactions()
        }
    }
    
    var allTransactions = [Transaction]()
    
    var balance: UInt64 {
        didSet {
            delegate?.balanceDidChange(number: balance)
        }
    }
    
    var passcode: String? {
        return keychain.pin
    }
    
    var isLocked: Bool {
        return keychain.isLocked
    }
    
    var isTouchIdEnabled: Bool {
        return defaultsProvider.isTouchIdEnabled
    }
    
    weak var delegate: GeneralVMDelegate? {
        didSet {
            delegate?.balanceDidChange(number: balance)
        }
    }
    
    weak var walletProvider: WalletProvider!
    weak var accountProvider: AccountManager?
    weak var icloudProvider: ICloud?
    weak var defaultsProvider: Defaults!
    weak var contactsProvider: ContactsProvider?
    weak var ratesProvider: RatesProvider?
    weak var taskQueueProvider: TaskQueueProvider?
    weak var feeProvider: FeeProvider?
    var keychain: Keychain
    
    // MARK: - Lifecycle
    init(walletProvider: WalletProvider, keychain: Keychain, accountProvider: AccountManager, icloudProvider: ICloud, defaultsProvider: Defaults, contactsProvider: ContactsProvider, ratesProvider: RatesProvider, taskQueueProvider: TaskQueueProvider, feeProvider: FeeProvider) {

        self.walletProvider = walletProvider
        self.keychain = keychain
        self.balance = 0
        self.dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        self.updateBalance()
        self.accountProvider = accountProvider
        self.icloudProvider = icloudProvider
        self.defaultsProvider = defaultsProvider
        self.ratesProvider = ratesProvider
        self.contactsProvider = contactsProvider
        self.feeProvider = feeProvider
        self.taskQueueProvider?.start()
        walletProvider.peerManager.connect()
        ratesProvider.startTimer()
        feeProvider.startTimer()
        
        let notifyName = "BRWalletBalanceChangedNotification"
        let reachNotify = "NetworkReachabilityChangedNotification"
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance), name: NSNotification.Name(rawValue: notifyName), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(checkReachabilityStatus), name: NSNotification.Name(rawValue: reachNotify), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLockStatus(_:)), name: .didUpdateLockStatus, object: nil)
    }
    
    @objc func didChangeIsTouchIdEnabled(_ notification: Notification) {
        if let isTouchIdEnabled = notification.object as? Bool {
            delegate?.didChangeIsTouchIdEnabled(isTouchIdEnabled)
        }
    }

    @objc func updateBalance() {
        if let balanceInt = self.walletProvider?.manager.wallet?.balance {
            balance = balanceInt
        }
        getTransactions()
    }
    
    @objc func didUpdateLockStatus(_ notification: Notification) {
        if let isLocked = notification.object as? Bool {
            delegate?.didChangeLockStatus(isLocked)
        }
    }
    
    func getTransactions() {
        guard let bTransactions = walletProvider?.manager.wallet?.allTransactions as? [BRTransaction] else {
            return
        }
        
        let sorted = bTransactions.reversed()
        
        let allContacts = contactsProvider?.allContacts()
        
        let transactionsInterim = sorted.map { transaction -> Transaction in
            let rates = ratesProvider?.ratesForTx(transaction: transaction) ?? []
            let txHash = UInt256S(transaction.txHash)
            if let contact = contactsProvider?.getContact(txHash: txHash) {
                let isNotificationTx = (contact as? PaymentCodeContact)?.isContactForNotificationTransaction(txHash: txHash)
                return Transaction(brTransaction: transaction, contact: contact, isNotificationTx: isNotificationTx ?? false, rates: rates)
            } else if let contact = contactsProvider?.getContactForNotification(txHash: txHash) {
                return Transaction(brTransaction: transaction, contact: contact, isNotificationTx: true, rates: rates)
                
            } else {
                let contact = allContacts?.filter({ $0.isContact(for: transaction) }).first
                return Transaction(brTransaction: transaction, contact: contact, isNotificationTx: false, rates: rates)
            }
            
        }
        
        allTransactions = transactionsInterim
        filteredTransactions = allTransactions
    }
    
    func checkWalletDigest() {
        guard accountProvider?.currentWalletDigest != nil else {
            _ = accountProvider?.createNewWalletDigest()
            return
        }        
    }
    
    func restoreUserNotesIfNeeded() {
        if !defaultsProvider.isBackupRestored {
            icloudProvider?.restoreComments(walletProvider: walletProvider)
        }
    }
    
    @objc func checkReachabilityStatus(notification: NSNotification) {
        if let reachability = notification.object as? Reachability {
            let status = reachability.currentReachabilityStatus() == NotReachable
            delegate?.reachabilityDidChange(status: status)
        }
    }
    
    func currentSyncStatus() -> SyncStatus {
        let peerMan = walletProvider.peerManager
        if peerMan.syncProgress < 1.0 {
            if !peerMan.isConnectedToDownloadPeer() {
                return .connecting
            } else {
                return .syncing
            }
        } else {
            return .synced
        }
    }
    
    func currentSyncPercent() -> Double {
        let peerMan = walletProvider.peerManager
        let syncProgress = peerMan.syncProgress
        return syncProgress
    }
    
    func currentBlock() -> BRMerkleBlock {
        let peerMan = walletProvider.peerManager
        return peerMan.lastBlock()
    }
    
    func currentBlockDate() -> String {
        let blockTs = currentBlock().timestamp
        let date = Date(timeIntervalSince1970: TimeInterval(blockTs))
        return dateFormatter.string(from: date)
    }
    
    func estimatedBlockHeight() -> UInt32 {
        let peerMan = walletProvider.peerManager
        return peerMan.estimatedBlockHeight
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - PasscodeOutputDelegate

extension GeneralVM: PasscodeOutputDelegate {
    
    func didCompleteVerification() {
        
    }
    
    func didUpdatePascode(_ passcode: String) {
        keychain.pin = passcode
    }
    
}

// MARK: - FilterViewDelegate

extension GeneralVM: FilterViewDelegate {
    
    func didAddFilter(_ filter: FilterView.Filter) {
        currentFilter = filter
        filteredTransactions = allTransactions.filter { tx in
            
            var sendedFiltred = true
            if let sended = filter.sended {
                sendedFiltred =  tx.isReceived == !sended
            }
            
            var timestampFiltred = true
            if let timestamp = tx.timestamp, let filterDate = filter.selectedDate {
                timestampFiltred = Calendar.current.isDate(timestamp, inSameDayAs: filterDate)
            }
            
            return sendedFiltred && timestampFiltred
        }
        delegate?.didSelectFilter(true)
    }
    
    func didRemoveFilters() {
        currentFilter = nil
        filteredTransactions = allTransactions
        delegate?.didSelectFilter(false)
    }
}
