//
//  SettingsCommissionRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct SettingsCommissionRouter: Router {
    
    let mainRouter: MainRouter
    
    // MARK: - Start routing
    func run() {
        // MARK: Inject dependencies or address only from mainRouter?.application to viewModel
        let viewModel = SettingsCommissionVM(defaultsProvider: mainRouter.application.defaults)
        let viewController = SettingsCommissionViewController(viewModel: viewModel)
        mainRouter.navigationController.push(viewController: viewController)
    }
    
}
