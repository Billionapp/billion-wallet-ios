//
//  SettingsCurrencyRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct SettingsCurrencyRouter: Router {
    
    let mainRouter: MainRouter
    
    // MARK: - Start routing
    func run() {
        // MARK: Inject dependencies or address only from mainRouter?.application to viewModel
        let viewModel = SettingsCurrencyVM(defaultsProvider: mainRouter.application.defaults, walletProvider:mainRouter.application.walletProvider)
        let viewController = SettingsCurrencyViewController(viewModel: viewModel)
        mainRouter.navigationController.push(viewController: viewController)
    }
    
}
