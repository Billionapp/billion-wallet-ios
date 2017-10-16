//
//  WalletRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class WalletRouter: Router {
    
    weak var mainRouter: MainRouter?
    
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    func run() {
        guard let router = mainRouter else {return}
        let viewModel = WalletVM(walletProvider: router.application.walletProvider, yieldProvider: router.application.yieldProvider, defaults: router.application.defaults, ratesProvider: router.application.ratesProvider, feeProvider: router.application.feeProvider)
        let viewController = WalletViewController(viewModel: viewModel)
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.router = mainRouter
        router.navigationController.modal(viewController: viewController)
    }
}
