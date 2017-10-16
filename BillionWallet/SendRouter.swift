//
//  SendRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class SendRouter: Router {
    
    // MARK: - Private
    weak var mainRouter: MainRouter?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    // MARK: - Start routing
    func run() {
        guard let mainRouter = mainRouter else { return }
        
        // MARK: Inject dependencies or address only from mainRouter?.application to viewModel
        let viewModel = SendVM(walletProvider: mainRouter.application.walletProvider, scanProvider: mainRouter.application.scannerProvider, defaultsProvider: mainRouter.application.defaults, contactsProvider: mainRouter.application.contactsProvider,notificationTransactionProvider: mainRouter.application.notificationTransactionProvider, icloudProvider: mainRouter.application.iCloud, api: mainRouter.application.api, feeProvider: mainRouter.application.feeProvider, rateProvider: mainRouter.application.ratesProvider)
        let sendViewController = SendViewController(viewModel: viewModel)
        sendViewController.mainRouter = mainRouter
        mainRouter.navigationController.push(viewController: sendViewController)
    }
}
