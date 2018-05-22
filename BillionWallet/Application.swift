//
//  Application.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class Application: NSObject {
    
    // MARK: - Dependencies
    private let window: UIWindow
    lazy var mainRouter: MainRouter = MainRouter(
        window: self.window,
        navigationController: UINavigationController(),
        application: self
    )
    
    private lazy var brWalletManager = BRWalletManager.sharedInstance()!
    private lazy var brPeerManager = BRPeerManager.sharedInstance()!
    
    // MARK: - Global Providers
    @objc
    lazy var walletProvider = WalletProvider(manager: self.brWalletManager, peerManager: self.brPeerManager)
    lazy var network                = NetworkProvider(session: URLSession.shared)
    lazy var api: API               = API(network: self.network)
    lazy var messageFetchProvider = MessageFetchProviderFactory(api: api,
                                                                accountManager: accountProvider,
                                                                contactsProvider: contactsProvider,
                                                                userPaymentRequestProvider: userPaymentRequestProvider,
                                                                selfPaymentRequestProvider: selfPaymentRequestProvider).createFetcher()
    lazy var messageSendProvider    = RequestSendProviderFactory(api: api,
                                                                 accountManager: accountProvider,
                                                                 contactsProvider: contactsProvider,
                                                                 userPaymentRequestProvider: userPaymentRequestProvider,
                                                                 selfPaymentRequestProvider: selfPaymentRequestProvider).create()
    lazy var imageCache: ImageCache = ImageCacheProvider(network: self.network)
    lazy var defaults               = Defaults()
    lazy var keychain               = Keychain()
    lazy var touchId                = TouchIdProvider(defaults: self.defaults)
    lazy var accountProvider        = AccountManager.shared
    lazy var authProvider           = AuthorizationProvider(accountProvider: self.accountProvider,
                                                            api: self.api,
                                                            defaults: self.defaults,
                                                            icloudProvider: self.iCloud)
    lazy var iCloud: ICloud         = ICloud(accountManager: self.accountProvider)
    
    @objc
    lazy var pcProvider: PaymentCodesProvider   = PaymentCodesProvider(accountProvider: self.accountProvider,
                                                                       walletProvider: self.walletProvider,
                                                                       contactsProvider: self.contactsProvider,
                                                                       apiProvider: self.api,
                                                                       transactionRelator: transactionRelator,
                                                                       transactionLinker: transactionLinker)
    lazy var blurLocker: BlurLocker             = BlurLocker(window: self.window)
    lazy var addContactProvider: AddContactProvider = AddContactProvider(icloud: self.iCloud, accountProvider: accountProvider)
    lazy var taskQueueProvider: TaskQueueProvider = TaskQueueProvider(authorizationProvider: self.authProvider,
                                                                      accountProvider: self.accountProvider,
                                                                      defaults: self.defaults,
                                                                      profileUpdater: self.profileUpdater,
                                                                      pushConfigurator: self.pushConfigurator)
    lazy var profileUpdater: ProfileUpdateManager = ProfileUpdateManager(api: self.api,
                                                                         icloud: self.iCloud)
    lazy var urlComposer: BillionUriComposer    = BillionUriComposer()
    lazy var tapticService: TapticService       = TapticService()
    lazy var urlHelper: UrlHelper               = UrlHelper()
    lazy var confirmMinuterFormatter: ConfirmationMinutesFormatter = ConfirmationMinutesFormatter()
    lazy var defaultRateSource = DefaultRateSource(rateProvider: self.ratesProvider)
    lazy var fiatConverter = FiatConverter(currency: self.defaults.currencies.first!, ratesSource: self.defaultRateSource)
    
    // MARK: - Object Providers
    lazy var scannerProvider: ScannerDataProvider    = ScannerDataProvider(scannedString: "")
    lazy var txProvider: TransactionProvider         = TransactionProvider(tx: nil, fee: nil, amount: nil)
    @objc
    lazy var contactsProvider: ContactsProvider   = {
        let groupProvider = GroupFolderProviderFactory().create()
        let queueIdProvider = QueueIdReceiveProvider(accountManager: self.accountProvider)
        let provider = ContactsProvider(iCloudProvider: self.iCloud, groupProvider: groupProvider, queueIdProvider: queueIdProvider)
        provider.setChannel(self.channelRepository.contactsChannel)
        return provider
    }()
    lazy var rateQ: RateQueueProtocol = RateQueue(api: self.api)
    lazy var ratesProvider: RateProviderProtocol  = RateProviderFactory(api: self.api, rateQ: self.rateQ).create()
    lazy var userPaymentRequestProvider: UserPaymentRequestProtocol = DefaultUserPaymentRequestProviderFactory().createUserPaymentRequestProvider()
    lazy var selfPaymentRequestProvider: SelfPaymentRequestProtocol = DefaultSelfPaymentRequestProviderFactory().createSelfPaymentRequestProvider()
    lazy var failureTxProvider: FailureTxProtocol = DefaultFailureTxProviderFactory().createFailureTxProvider()
    lazy var feeProvider: FeeProvider           = DefaultFeeProviderFactory(apiProvider: self.api).createFeeProvider()
    lazy var lockProvider: LockProvider       = LockService(keychain: self.keychain)
    lazy var notesProvider: TransactionNotesProvider = TransactionNotesProvider()
    
    lazy var migrationManager: MigrationManagerProtocol = MainMigrationManagerFactory(defaults: UserDefaults.standard,
                                                                                      fileManager: FileManager.default,
                                                                                      accountManager: self.accountProvider,
                                                                                      walletProvider: walletProvider,
                                                                                      txLinker: transactionLinker,
                                                                                      txRelator: transactionRelator,
                                                                                      contactsProvider: contactsProvider,
                                                                                      app: self,
                                                                                      keychain: keychain,
                                                                                      queueIdProvider: QueueIdReceiveProvider(accountManager: self.accountProvider),
                                                                                      groupProvider: GroupFolderProviderFactory().create()).createManager()
    
    lazy var transactionRelator: TransactionRelatorProtocol = TransactionRelator(accountProvier: accountProvider)
    lazy var transactionLinker: TransactionLinkerProtocol = TransactionLinker(contactProvider: contactsProvider)
    
    lazy var authChecker: AuthCheckerProtocol = AuthChecker(authProvider: self.authProvider,
                                                            taskQProvider: self.taskQueueProvider)
    
    lazy var channelRepository: ChannelRepository = ChannelRepository()
    lazy var pushConfigurator: PushConfigurator = {
        let configurator = PushConfigurator(api: self.api, defaults: self.defaults, queueIdProvider: QueueIdReceiveProvider(accountManager: self.accountProvider), contactsProvider: self.contactsProvider)
        configurator.setContactChannel(self.channelRepository.contactsChannel)
        return configurator
    }()
    lazy var notificationProvider: UNProvider = NotificationProvider()
    lazy var groupRequestRestoreProvider = GroupRequestRestoreProviderFactory(requestProvider: self.userPaymentRequestProvider, selfRequestProvider: self.selfPaymentRequestProvider).create()
    
    
    // MARK: - Lifecycle
    init(window: UIWindow) {
        self.window = window
    }
}
