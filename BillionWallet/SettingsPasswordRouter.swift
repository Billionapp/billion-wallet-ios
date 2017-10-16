//
//  SettingsPasswordRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsPasswordRouter: Router {
    
    let mainRouter: MainRouter
    
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    func run() {
        let viewModel = SettingsPasswordVM(application: mainRouter.application)
        let viewController = SettingsPasswordViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }

}
