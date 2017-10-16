//
//  AddWalletRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddWalletRouter: Router {
    
    let mainRouter: MainRouter
    
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    func run() {

        let viewModel = AddWalletVM(walletProvider:mainRouter.application.walletProvider, icloudProvider: mainRouter.application.iCloud, defaultsProvider: mainRouter.application.defaults, accountProvider: mainRouter.application.accountProvider, pcProvider: mainRouter.application.pcProvider, contactsProvider: mainRouter.application.contactsProvider, taskQueueProvider: mainRouter.application.taskQueueProvider)
        let viewController = AddWalletViewController(viewModel: viewModel)
        viewController.router = self
        mainRouter.navigationController.push(viewController: viewController)
    }
    
    func showNewWalletView(with info: SettingsRestoreVM.Info) {
        mainRouter.showRestoreSettingsView(with: info)
    }
    
    func showRestoreWalletView() {
        mainRouter.showGeneralView()
    }
}
