//
//  SettingsAboutRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsAboutRouter: Router {
    
    private let mainRouter: MainRouter
    private let back: UIImage?
    private let walletManager: BWalletManager
    
    init(mainRouter: MainRouter, backImage: UIImage?, walletManager: BWalletManager) {
        self.mainRouter = mainRouter
        self.back = backImage
        self.walletManager = walletManager
    }
    
    func run() {
        let viewModel = SettingsAboutVM(walletManager: walletManager)
        let viewController = SettingsAboutViewController(viewModel: viewModel)
        viewController.backImage = back
        mainRouter.navigationController.push(viewController: viewController)
    }

}
