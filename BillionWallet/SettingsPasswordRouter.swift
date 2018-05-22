//
//  SettingsPasswordRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsPasswordRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private let back: UIImage?
    
    init(mainRouter: MainRouter, app: Application, back: UIImage?) {
        self.mainRouter = mainRouter
        self.app = app
        self.back = back
    }
    
    func run() {
        let viewModel = SettingsPasswordVM(application: app)
        let viewController = SettingsPasswordViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = back
        mainRouter.navigationController.push(viewController: viewController)
    }

}
