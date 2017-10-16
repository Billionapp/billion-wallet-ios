//
//  MainRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class MainRouter: Router {
    
    // MARK: - Private
    //private var childRouters = [Router]()
    private weak var generalViewController: GeneralViewController?
    
    // MARK: - Public
    let navigationController: UINavigationController
    let application: Application
    
    // MARK: - Lifecycle
    init(window: UIWindow, navigationController: UINavigationController, application: Application) {
        self.application = application
        self.navigationController = navigationController
        navigationController.navigationBar.isHidden = true
        window.rootViewController = self.navigationController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Start routing
    func run() {
        showSplash()
        if application.walletProvider.manager.noWallet {
            showAddWalletView()
        } else {
            showGeneralView()
        }
    }
    
    // MARK: - Splash
    func showSplash() {
        let splash = SplashView.init()
        UIApplication.shared.keyWindow?.addSubview(splash)
    }
    
    // MARK: - Start view
    func showAddWalletView() {
        let router = AddWalletRouter(mainRouter: self)
        router.run()
    }
    
    // MARK: - General view
    func showGeneralView() {
        let walletProvider = application.walletProvider
        let viewModel = GeneralVM(walletProvider: walletProvider, keychain: application.keychain, accountProvider: application.accountProvider, icloudProvider: application.iCloud, defaultsProvider: application.defaults, contactsProvider: application.contactsProvider, ratesProvider: application.ratesProvider, taskQueueProvider: application.taskQueueProvider, feeProvider: application.feeProvider)

        let controller = GeneralViewController(viewModel: viewModel)
        controller.mainRouter = self
        navigationController.setViewControllers([controller], animated: false)
        generalViewController = controller
    }
    
    
    // MARK: - Receive view
    func showReceiveView() {
        let receiveRouter = ReceiveRouter(mainRouter: self)
        receiveRouter.run()
    }
    
    // MARK: - Send view
    func showSendView() {
        let sendRouter = SendRouter(mainRouter: self)
        sendRouter.run()
    }
    
    // MARK: - Send view
    func showContactsView(output: ContactsOutputDelegate?, mode: ContactsVM.Mode, back: UIImage) {
        let contactsRouter = ContactsRouter(mainRouter: self, output: output, mode: mode, back: back)
        contactsRouter.run()
    }
    
    // MARK: - Scan view
    func showScanView(isPrivate key: Bool) {
        let scanRouter = ScanRouter(mainRouter: self)
        scanRouter.run()
    }
    
    // MARK: - Import key view
    func showImportKeyView() {
        let importKeyRouter = ImportKeyRouter(mainRouter: self)
        importKeyRouter.run()
    }
    
    // MARK: - Passcode view
    func showPasscodeView(passcodeCase: PasscodeCase, output: PasscodeOutputDelegate?) {
        let router = PasscodeRouter(mainRouter: self, passcodeCase: passcodeCase, output: output, lockDelegate: application.lockProvider)
        router.run()
    }
    
    //MARK: - Custom Fee View 
    func showCustomFeeView(transaction: BRTransaction?, completion: FeeVM.Completion?) {
        let router = FeeRouter(mainRouter: self, networkProvider: application.network, transaction: transaction, completion: completion)
        router.run()
    }
    
    //MARK: - Show Contact Card View
    func showContactCardView(contact: ContactProtocol) {
        let router = ContactCardRouter(mainRouter: self, contact: contact)
        router.run()
    }
    
    //MARK: - Show Transaction Detail
    func showTransactionDetails(transaction: Transaction, back: UIImage) {
        let detailRouter = TxDetailsRouter(mainRouter: self, transaction: transaction, back: back)
        detailRouter.run()
    }
    
    //MARK: - Show Wallet View
    func showWalletView() {
        let router = WalletRouter(mainRouter: self)
        router.run()
    }
    
    //MARK: - Show Profile View
    func showProfileView(back: UIImage) {
        let router = ProfileRouter(mainRouter: self, back: back)
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
    
    @objc func popToGeneralView() {
        if let destinationVC = self.viewControllers.filter({$0 is GeneralViewController}).first {
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
