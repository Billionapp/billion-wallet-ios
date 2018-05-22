//
//  TxFailureDetailsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxFailureDetailsRouter: Router {

    private let mainRouter: MainRouter
    private let app: Application
    private let displayer: FailureTxDisplayer
    private let back: UIImage?
    private let cellY: CGFloat

    init(mainRouter: MainRouter,
         application: Application,
         displayer: FailureTxDisplayer,
         back: UIImage?,
         cellY: CGFloat) {
        
        self.mainRouter = mainRouter
        self.app = application
        self.displayer = displayer
        self.back = back
        self.cellY = cellY
    }

    func run() {
        let viewModel = TxFailureDetailsVM(displayer: displayer,
                                           failureTransactionProvider: app.failureTxProvider,
                                           walletProvider: app.walletProvider,
                                           ratesProvider: app.ratesProvider,
                                           defaults: app.defaults,
                                           cellY: cellY)
        let viewController = TxFailureDetailsViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = back
        
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        let balanceVM = BillionBalanceVM(defaults: app.defaults,
                                         peerManager: app.walletProvider,
                                         wallet: app.walletProvider,
                                         lockProvider: app.lockProvider,
                                         fiatConverter: app.fiatConverter,
                                         localAuthProvider: TouchIDManager())
        balanceView.setVM(balanceVM)
        viewController.addBalanceView(balanceView)
        
        mainRouter.navigationController.push(viewController: viewController)
    }
}
