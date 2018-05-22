//
//  MainRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class MainRouter: Router {
    
    // MARK: - Public
    let navigationController: UINavigationController
    private let app: Application
    
    // MARK: - Lifecycle
    init(window: UIWindow, navigationController: UINavigationController, application: Application) {
        self.app = application
        self.navigationController = navigationController
        navigationController.navigationBar.isHidden = true
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Start routing
    func run() {
        showMigrationView()
    }
    
    // MARK: - StartScreen
    func showStartScreen() {
        if app.walletProvider.noWallet {
            showOnboarding()
        } else {
            if app.defaults.appStarted {
                showGeneralContainerView()
            } else {
                showBiometricSetup()
            }
        }
    }
    
    //MARK: - GeneralContainer
    func showGeneralContainerView() {
        let viewModel = GeneralContainerVM(router: self)
        let viewController = GeneralContainerViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    //MARK: - Onboarding
    func showOnboarding() {
        let router = OnboardRouter(mainRouter: self, app: app)
        router.run()
    }

    func showBiometricSetup() {
        let router = SetupBioRouter(mainRouter: self, defaults: app.defaults, keychain: app.keychain, iCloudProvider: app.iCloud)
        router.run()
    }
    
    func showAbout() {
        let router = AboutRouter(mainRouter: self)
        router.run()
    }
    
    func showPrivacyPolicy() {
        let router = PrivacyRouter(mainRouter: self)
        router.run()
    }
    
    // MARK: - Migration View
    func showMigrationView() {
        let router = MigrationRouter(mainRouter: self, app: app, migrationManager: app.migrationManager)
        router.run()
    }
    
    // MARK: - Start view
    func showAddWalletView() {
        let router = AddWalletRouter(mainRouter: self, app: app)
        router.run()
    }
    
    // MARK: - General view
    func getGeneralView() -> UIViewController {
        let routingVisitor = HistoryDisplayableVisitor(mainRouter: self)
        let walletProvider = app.walletProvider
        app.taskQueueProvider.start()
        let viewModel = GeneralVM(walletProvider: walletProvider,
                                  keychain: app.keychain,
                                  accountProvider: app.accountProvider,
                                  icloudProvider: app.iCloud,
                                  defaultsProvider: app.defaults,
                                  contactsProvider: app.contactsProvider,
                                  ratesProvider: app.ratesProvider,
                                  feeProvider: app.feeProvider,
                                  userPaymentRequestProvider: app.userPaymentRequestProvider,
                                  selfPaymentRequestProvider: app.selfPaymentRequestProvider,
                                  failureTransactionProvider: app.failureTxProvider,
                                  routingVisitor: routingVisitor,
                                  tapticService: app.tapticService,
                                  messageFetchProvider: app.messageFetchProvider,
                                  fiatConverter: app.fiatConverter,
                                  authChecker: app.authChecker)
        viewModel.setContactChannel(app.channelRepository.contactsChannel)

        let controller = GeneralViewController(viewModel: viewModel)
        
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        let balanceVM = BillionBalanceVM(defaults: app.defaults,
                                         peerManager: app.walletProvider,
                                         wallet: app.walletProvider,
                                         lockProvider: app.lockProvider,
                                         fiatConverter: app.fiatConverter,
                                         localAuthProvider: TouchIDManager())
        balanceView.setVM(balanceVM)
        controller.addBalanceView(balanceView)
        controller.mainRouter = self
        return controller
    }
    
    // MARK: - Get shop view
    func getShopView() -> UIViewController {
        let shopsFactory = ShopsFactory()
        let viewModel = ShopVM(shopsFactory: shopsFactory)
        let viewController = ShopViewController(viewModel: viewModel)
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        let balanceVM = BillionBalanceVM(defaults: app.defaults,
                                         peerManager: app.walletProvider,
                                         wallet: app.walletProvider,
                                         lockProvider: app.lockProvider,
                                         fiatConverter: app.fiatConverter,
                                         localAuthProvider: TouchIDManager())
        balanceView.setVM(balanceVM)
        viewController.addBalanceView(balanceView)
        viewController.router = self
        return viewController
    }
    
    // MARK: - Get buy view
    func getBuyView() -> UIViewController {
        let exchangesService = ExchangesServiceFactory(network: app.network).create()
        let viewModel = BuyVM(exchangesService: exchangesService)
        let viewController = BuyViewController(viewModel: viewModel)
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        let balanceVM = BillionBalanceVM(defaults: app.defaults,
                                         peerManager: app.walletProvider,
                                         wallet: app.walletProvider,
                                         lockProvider: app.lockProvider,
                                         fiatConverter: app.fiatConverter,
                                         localAuthProvider: TouchIDManager())
        balanceView.setVM(balanceVM)
        viewController.addBalanceView(balanceView)
        viewController.router = self
        return viewController
    }
    
    // MARK: - Show buy picker view
    func showBuyPickerView(method: PaymentMethod?, methods: [String]?, back: UIImage?, output: BuyPickerOutputDelegate?) {
        let router = BuyPickerRouter(mainRouter: self, back: back)
        router.run(method: method, methods: methods, output: output)
    }
    
    // MARK: - Receive view
    func showReceiveView(back: UIImage?) {
        let receiveRouter = ReceiveRouter(mainRouter: self, back: back, app: app)
        receiveRouter.run()
    }
    
    func showChooseReceiver(back: UIImage, conveyor: TouchConveyorView?) {
        let chooseReceiverRouter = ChooseReceiverRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseReceiverRouter.run()
    }
    
    func showSendInputContactView(contact: PaymentCodeContactProtocol, failureTransaction: FailureTx?, back: UIImage?) {
        let sendInputRouter = SendInputContactRouter(mainRouter: self, application: self.app, back: back)
        sendInputRouter.run(contact: contact, failureTransaction: failureTransaction)
    }
    
    func showSendInputContactView(displayer: UserPaymentRequestDisplayer, contact: PaymentCodeContactProtocol, back: UIImage?) {
        let sendInputRouter = SendInputContactRouter(mainRouter: self, application: self.app, back: back)
        sendInputRouter.run(displayer: displayer, contact: contact)
    }
    
    func showSendInputAddressView(paymentRequest: PaymentRequest, userPaymentRequest: UserPaymentRequest?, failureTransaction: FailureTx?, back: UIImage?) {
        let sendInputRouter = SendInputAddressRouter(mainRouter: self, application: self.app, back: back)
        sendInputRouter.run(paymentRequest: paymentRequest, userPaymentRequest: userPaymentRequest, failureTransaction: failureTransaction)
    }
    
    func showChooseFeeAddressView(address: String, amount: UInt64, back: UIImage?, conveyor: TouchConveyorView?, userNote: String?) {
        let chooseFeeRouter = ChooseFeeAddressRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseFeeRouter.run(address: address, amount: amount, userNote: userNote)
    }
    
    func showChooseFeeAddressView(failureTx: FailureTx, back: UIImage?, conveyor: TouchConveyorView?, userNote: String?) {
        let chooseFeeRouter = ChooseFeeAddressRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseFeeRouter.run(failureTx: failureTx, userNote: userNote)
    }
    
    func showChooseFeeAddresView(userPaymentRequest: UserPaymentRequest, back: UIImage?, conveyor: TouchConveyorView?, userNote: String?) {
        let chooseFeeRouter = ChooseFeeAddressRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseFeeRouter.run(userPaymentRequest: userPaymentRequest, userNote: userNote)
    }
    
    func showChooseFeeContactView(contact: PaymentCodeContactProtocol, amount: UInt64, back: UIImage?, conveyor: TouchConveyorView?, userNote: String?) {
        let chooseFeeRouter = ChooseFeeContactRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseFeeRouter.run(contact: contact, amount: amount, userNote: userNote)
    }
    
    func showChooseFeeContactView(contact: PaymentCodeContactProtocol, failureTx: FailureTx, back: UIImage?, conveyor: TouchConveyorView?, userNote: String?) {
        let chooseFeeRouter = ChooseFeeContactRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseFeeRouter.run(contact: contact, failureTx: failureTx, userNote: userNote)
    }
    
    func showChooseFeeContactView(displayer: UserPaymentRequestDisplayer, contact: PaymentCodeContactProtocol, back: UIImage?, conveyor: TouchConveyorView?, userNote: String?) {
        let chooseFeeRouter = ChooseFeeContactRouter(mainRouter: self, application: self.app, back: back, conveyor: conveyor)
        chooseFeeRouter.run(displayer: displayer, contact: contact, userNote: userNote)
    }
    
    // MARK: - Send view
    func showContactsView(output: ContactsOutputDelegate?, mode: ContactsVM.Mode, back: UIImage) {
        let contactsRouter = ContactsRouter(mainRouter: self, output: output, mode: mode, app: app)
        contactsRouter.run()
    }
    
    func popAddContactCard() {
        if let contactViewController = navigationController.viewControllers.first(where: { $0 as? ContactsViewController != nil || $0 as? ChooseReceiverViewController != nil || $0 as? ChooseSenderViewController != nil}) {
            navigationController.popToViewController(contactViewController, animated: true)
        } else {
            navigationController.popToGeneralView()
        }
    }
    
    func rollbackToContactList() {
        let controllers = navigationController.viewControllers
        if let destinationVc = controllers.filter({ $0 is ContactsViewController }).first {
            navigationController.popToViewController(destinationVc, animated: true)
        } else {
            navigationController.popToGeneralView()
        }
    }
    
    // MARK: - Scan view
    func showScanView(resolver: QrResolver) {
        let scanRouter = ScanRouter(mainRouter: self, app: app, qrResolver: resolver)
        scanRouter.run()
    }
    
    // MARK: - Passcode view
    func showPasscodeView(passcodeCase: PasscodeCase, output: PasscodeOutputDelegate?, reason: String? = nil) {
        let router = PasscodeRouter(mainRouter: self,
                                    passcodeCase: passcodeCase,
                                    output: output,
                                    app: app,
                                    reason: reason)
        router.run()
    }
    
    //MARK: - Show Contact Card View
    func showContactCardView(contact: ContactProtocol, back: UIImage) {
        let router = ContactCardRouter(mainRouter: self,
                                       contact: contact,
                                       urlComposer: app.urlComposer,
                                       backImage: back,
                                       contactProvider: app.contactsProvider,
                                       apiProvider: app.api)
        router.run()
    }
    
    //MARK: - Show Transaction Detail
    func showTransactionDetails(displayer: TransactionDisplayer, back: UIImage, cellY: CGFloat) {
        let detailRouter = TxDetailsRouter(mainRouter: self, app: app, displayer: displayer, back: back, cellY:cellY)
        detailRouter.run()
    }
    
    //MARK: - Show Notification Transaction Detail
    func showNotificationTransactionDetails(displayer: TransactionDisplayer, back: UIImage, cellY: CGFloat) {
        let router = NotificationTxDetailsRouter(mainRouter: self, displayer: displayer, app: app, cellY: cellY, backImage: back)
        router.run()
    }
    
    //MARK: - Setup Profile Card
    func showSetupCard(image: Data?, name: String?) {
        let router = SetupCardRouter(mainRouter: self, app: app, image: image, name: name)
        router.run()
    }
    
    //MARK: - Show Profile View
    func showProfileView(back: UIImage) {
        let router = ProfileRouter(mainRouter: self, app: app, back: back)
        router.run()
    }
    
    //MARK: - Show Add Contact View
    func showAddContactView(back: UIImage) {
        let router = AddContactRouter(mainRouter: self,
                                    app: app,
                                    addContactProvider: app.addContactProvider,
                                    contactsProvider: app.contactsProvider,
                                    back: back)
        router.run()
    }
    
    //MARK: - Show Add Contact Card View
    func showAddContactCardView(contact: ContactProtocol, back: UIImage) {
        let router = AddContactCardRouter(mainRouter: self,
                                          contact: contact,
                                          backImage: back,
                                          contactsProvider: app.contactsProvider,
                                          transactionLinker: app.transactionLinker,
                                          transactionRelator: app.transactionRelator,
                                          paymentCodesProvider: app.pcProvider)
        router.run()
    }
    
    //MARK: - Show Search Contact View
    func showSearchContactView(back: UIImage, billionCode: String) {
        let router = SearchContactRouter(mainRouter: self,
                                         app: app,
                                         billionCode: billionCode,
                                         backImage: back)
        router.run()
    }
  
    //MARK: - Show Choose Sender View
    func showChooseSenderView(back: UIImage, conveyor: TouchConveyorView?) {
        let router = ChooseSenderRouter(mainRouter: self, app: app, back: back, conveyor: conveyor)
        router.run()
    }
        
    //MARK: - Show Receive Input View
    func showReceiveInputView(contact: PaymentCodeContactProtocol, back: UIImage?) {
        let router = ReceiveInputRouter(mainRouter: self, application: app, contact: contact, back: back)
        router.run()
    }
    
    //MARK: = Show Transaction Failure Details View
    func showTxFailureDetailsView(displayer: FailureTxDisplayer, back: UIImage?, cellY: CGFloat) {
        let router = TxFailureDetailsRouter(mainRouter: self, application: app, displayer: displayer, back: back, cellY: cellY)
        router.run()
    }
    
    //MARK: - Show User Payment Request Details View
    func showPaymentRequestDetailsView(displayer: UserPaymentRequestDisplayer, back: UIImage?, cellY: CGFloat) {
        let router = PaymentRequestDetailsRouter(mainRouter: self, application: app, displayer: displayer, back: back, cellY: cellY)
        router.run()
    }
    
    // MARK: - Show Self Payment Request Details View
    func showSelfPaymentRequestDetails(displayer: SelfPaymentRequestDisplayer, back: UIImage?, cellY: CGFloat) {
        let router = SelfPaymentRequestDetailsRouter(mainRouter: self, application: app, displayer: displayer, back: back, cellY: cellY)
        router.run()
    }
}

// MARK: - Settings
extension MainRouter {
    
    func showSettingsView(back: UIImage) {
        let router = SettingsRouter(application: app, mainRouter: self, back: back)
        router.run()
    }
    
    func showCurrencySettingsView(back: UIImage?) {
        let router = SettingsCurrencyRouter(mainRouter: self, app: app, back: back)
        router.run()
    }
    
    func showPasswordSettingsView(back: UIImage?) {
        let router = SettingsPasswordRouter(mainRouter: self, app: app, back: back)
        router.run()
    }
    
    func showRestoreSettingsView(with info: SettingsRestoreVM.Info, back: UIImage?) {
        let router = SettingsRestoreRouter(mainRouter: self,
                                           info: info,
                                           icloudProvider: app.iCloud,
                                           defaultsProvider: app.defaults,
                                           back: back)
        router.run()
    }
    
    func showRestoreSettingsViewAsRoot(with info: SettingsRestoreVM.Info, back: UIImage?) {
        let router = SettingsRestoreRouter(mainRouter: self,
                                           info: info,
                                           icloudProvider: app.iCloud,
                                           defaultsProvider: app.defaults,
                                           back: back)
        router.runAsRoot()
    }
    
    func showAboutSettingsView(back: UIImage?) {
        let router = SettingsAboutRouter(mainRouter: self,
                                         backImage: back,
                                         walletManager: app.walletProvider)
        router.run()
    }
}

// MARK: - Decorate transitioning
public extension UINavigationController {
    
    func push(viewController vc: UIViewController, transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    func pop(transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.3) {
        self.addTransition(transitionType: type, duration: duration)
        self.popViewController(animated: false)
    }
    
    func popQuickly(transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.0) {
        self.addTransition(transitionType: type, duration: duration)
        self.popViewController(animated: false)
    }
    
    func addSwipeDown() {
        let g = UISwipeGestureRecognizer(target: self, action: #selector(popToGeneralView))
        g.direction = .down
        self.topViewController?.view.addGestureRecognizer(g)
        
    }
    
    func addSwipeDownPop() {
        let g = UISwipeGestureRecognizer(target: self, action: #selector(popBack))
        g.direction = .down
        self.topViewController?.view.addGestureRecognizer(g)
    }
    
    @objc func popBack() {
        popQuickly()
    }
    
    @objc func popToGeneralView() {
        if let destinationVC = self.viewControllers.filter({$0 is GeneralContainerViewController}).first {
            self.popToViewController(destinationVC, animated: true)
        }
    }
    
    func disableBackSwipe() {
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
}

public extension UIViewController {
    
    func modal(viewController vc: UIViewController) {
        let window = UIApplication.shared.keyWindow!
        if let modalVC = window.rootViewController?.presentedViewController {
            if (vc as? PasscodeViewController) == nil {
                modalVC.present(vc, animated: true, completion: nil)
            }
        } else {
            window.rootViewController!.present(vc, animated: true, completion: nil)
        }
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil) 
    }
    
    fileprivate func addTransition(transitionType type: String = kCATransitionFade, duration: CFTimeInterval = 0.3) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = type
        self.view.layer.add(transition, forKey: nil)
    }
    
}
