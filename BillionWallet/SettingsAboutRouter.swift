//
//  SettingsAboutRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct SettingsAboutRouter: Router {
    
    let mainRouter: MainRouter
    
    func run() {
        let viewModel = SettingsAboutVM()
        let viewController = SettingsAboutViewController(viewModel: viewModel)
        mainRouter.navigationController.push(viewController: viewController)
    }

}
