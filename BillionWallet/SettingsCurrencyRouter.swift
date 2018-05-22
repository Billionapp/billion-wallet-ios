//
//  SettingsCurrencyRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct SettingsCurrencyRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private let back: UIImage?
    
    init(mainRouter: MainRouter, app: Application, back: UIImage?) {
        self.mainRouter = mainRouter
        self.app = app
        self.back = back
    }
    
    // MARK: - Start routing
    func run() {
        let viewModel = SettingsCurrencyVM(defaultsProvider: app.defaults, walletProvider: app.walletProvider)
        let viewController = SettingsCurrencyViewController(viewModel: viewModel)
        viewController.backImage = back
        mainRouter.navigationController.push(viewController: viewController)
    }
    
}
