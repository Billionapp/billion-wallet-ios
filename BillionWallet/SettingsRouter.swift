//
//  SettingsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct SettingsRouter: Router {
    
    let mainRouter: MainRouter
    
    func run() {
        let viewModel = SettingsVM(defaultsProvider: mainRouter.application.defaults, keychain: mainRouter.application.keychain, iCloudProvider: mainRouter.application.iCloud, accountProvider: mainRouter.application.accountProvider, ratesProvider: mainRouter.application.ratesProvider, feeProvider: mainRouter.application.feeProvider)
        let viewController = SettingsViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }


}
