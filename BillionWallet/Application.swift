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
    
    // MARK: - Global Providers
    lazy var walletProvider = WalletProvider(manager: BRWalletManager.sharedInstance()!, peerManager: BRPeerManager.sharedInstance()!)
    lazy var network                = NetworkProvider(session: URLSession.shared)
    lazy var api: API               = API(network: self.network)
    lazy var imageCache: ImageCache = ImageCacheProvider(network: self.network)
    lazy var defaults               = Defaults()
    lazy var keychain               = Keychain()
    lazy var touchId                = TouchIdProvider(defaults: self.defaults)
    lazy var iCloud: ICloud         = ICloud()
    lazy var accountProvider        = AccountManager.shared
    lazy var authProvider           = AuthorizationProvider(accountProvider: self.accountProvider, api: self.api, defaults: self.defaults)
    lazy var notificationTransactionProvider: NotificationTransactionProvider  = NotificationTransactionProvider(walletProvider: self.walletProvider, paymentCodeProvider: pcProvider)
    @objc
    lazy var pcProvider: PaymentCodesProvider = PaymentCodesProvider(accountProvider: self.accountProvider, walletProvider: self.walletProvider, contactsProvider: self.contactsProvider)
    lazy var blurLocker: BlurLocker = BlurLocker(window: self.window)
 
    lazy var taskQueueProvider: TaskQueueProvider = TaskQueueProvider(authorizationProvider: self.authProvider, accountProvider: self.accountProvider, defaults: self.defaults)

    
    // MARK: - Object Providers
    lazy var scannerProvider    = ScannerDataProvider(scannedString: "")
    lazy var txProvider         = TransactionProvider(tx: nil, fee: nil, amount: nil)
    lazy var contactsProvider   = ContactsProvider()
    lazy var ratesProvider      = RatesProvider(apiProvider: self.api, walletProvider: self.walletProvider)
    lazy var yieldProvider      = YieldProvider(defaults: self.defaults)
    lazy var feeProvider        = FeeProvider(apiProvider: self.api)
    
    lazy var lockProvider       = LockProvider()
    
    // MARK: - Lifecycle
    init(window: UIWindow) {
        self.window = window
    }
}
