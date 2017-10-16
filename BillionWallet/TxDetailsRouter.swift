//
//  TxDetailsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxDetailsRouter: Router {
    
    private weak var mainRouter: MainRouter?
    let transaction: Transaction
    let back: UIImage
    
    init(mainRouter: MainRouter, transaction: Transaction, back: UIImage) {
        self.mainRouter = mainRouter
        self.transaction = transaction
        self.back = back
    }
    
    func run() {
        guard let mainRouter = mainRouter else { return }
        
        let viewModel = TxDetailsVM(transaction: transaction, walletProvider: mainRouter.application.walletProvider)
        let viewController = TxDetailsViewController(viewModel: viewModel)
        viewController.backForBlur = back
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
