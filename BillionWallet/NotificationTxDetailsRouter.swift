//
//  NotificationTxDetailsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class NotificationTxDetailsRouter: Router {

    let mainRouter: MainRouter
    let displayer: TransactionDisplayer
    let app: Application
    let cellY: CGFloat
    let backImage: UIImage?
    
    init(mainRouter: MainRouter, displayer: TransactionDisplayer, app: Application, cellY: CGFloat, backImage: UIImage?) {
        self.mainRouter = mainRouter
        self.displayer = displayer
        self.app = app
        self.cellY = cellY
        self.backImage = backImage
    }

    func run() {
        let currency = app.defaults.currencies.first!
        let viewModel = NotificationTxDetailsVM(displayer: displayer,
                                                walletProvider: app.walletProvider,
                                                cellY: cellY,
                                                urlHelper: app.urlHelper)
        let viewController = NotificationTxDetailsViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = backImage
        
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        
        let rateSource = HistoricalRatesSource(ratesProvider: app.ratesProvider)
        rateSource.set(time: displayer.time.timeIntervalSince1970)
        let historicalFiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
        
        let balanceVM = TxDetailsBalanceVM(defaults: app.defaults,
                                           peerManager: app.walletProvider,
                                           walletManager: app.walletProvider,
                                           lockProvider: app.lockProvider,
                                           fiatConverter: historicalFiatConverter,
                                           localAuthProvider: TouchIDManager())
        balanceVM.balance = displayer.balanceAfterTransaction
        balanceView.setVM(balanceVM)
        viewController.addBalanceView(balanceView)
        
        mainRouter.navigationController.push(viewController: viewController)
    }
}
