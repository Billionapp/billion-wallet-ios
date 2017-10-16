//
//  FeeRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

final class FeeRouter: Router {
    
    fileprivate weak var mainRouter: MainRouter?
    
    let transaction: BRTransaction?
    let completion: FeeVM.Completion?
    let networkProvider: NetworkProvider
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter, networkProvider: NetworkProvider, transaction: BRTransaction?, completion: FeeVM.Completion?) {
        self.mainRouter = mainRouter
        self.transaction = transaction
        self.completion = completion
        self.networkProvider = networkProvider
    }
    
    // MARK: - Start routing
    func run() {
        guard let mainRouter = mainRouter else { return }
        
        let txProvider = mainRouter.application.txProvider
        let walletProvider = mainRouter.application.walletProvider
        let viewModel = FeeVM(walletProvider: walletProvider, networkProvider: networkProvider, txProvider: txProvider, transaction: transaction, completion: completion)
        let feeViewController = FeeViewController(viewModel: viewModel)
        
        feeViewController.mainRouter = mainRouter
        mainRouter.navigationController.push(viewController: feeViewController)
    }
}

