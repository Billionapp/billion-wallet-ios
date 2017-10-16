//
//  ReceiveRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ReceiveRouter: Router {
    
    // MARK: - Private
    private weak var mainRouter: MainRouter?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    // MARK: - Start routing
    func run() {
        guard let mainRouter = mainRouter else { return }
        
        // MARK: Inject dependencies or address only from mainRouter?.application to viewModel
        let localeIso = mainRouter.application.walletProvider.manager.localCurrencyCode
        let walletProvider = mainRouter.application.walletProvider
        let ratesProvider = mainRouter.application.ratesProvider
        
        let viewModel = ReceiveVM(walletProvider: walletProvider, localeIso: localeIso!, ratesProvider: ratesProvider)
        let receiveViewController = ReceiveViewController(viewModel: viewModel)
        receiveViewController.mainRouter = mainRouter
        mainRouter.navigationController.push(viewController: receiveViewController)
    }
}
