//
//  AddWalletRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddWalletRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    
    init(mainRouter: MainRouter, app: Application) {
        self.mainRouter = mainRouter
        self.app = app
    }
    
    func run() {

        let viewModel = AddWalletVM(walletProvider: app.walletProvider,
                                    icloudProvider: app.iCloud,
                                    defaultsProvider: app.defaults,
                                    accountProvider: app.accountProvider,
                                    pcProvider: app.pcProvider,
                                    contactsProvider: app.contactsProvider,
                                    taskQueueProvider: app.taskQueueProvider)
        let viewController = AddWalletViewController(viewModel: viewModel)
        viewController.router = self
        mainRouter.navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showNewWalletView(with info: SettingsRestoreVM.Info) {
        mainRouter.showRestoreSettingsViewAsRoot(with: info, back: nil)
    }
    
    func showRestoreWalletView() {
        mainRouter.showBiometricSetup()
    }
    
    func showPrivacy() {
        mainRouter.showPrivacyPolicy()
    }
}
