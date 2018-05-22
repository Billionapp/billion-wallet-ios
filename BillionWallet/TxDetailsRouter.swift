//
//  TxDetailsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxDetailsRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    let displayer: TransactionDisplayer
    let back: UIImage
    let cellY: CGFloat
    
    init(mainRouter: MainRouter, app: Application, displayer: TransactionDisplayer, back: UIImage, cellY: CGFloat) {
        self.mainRouter = mainRouter
        self.app = app
        self.displayer = displayer
        self.back = back
        self.cellY = cellY
    }
    
    func run() {
        let viewModel = TxDetailsVM(displayer: displayer,
                                    walletProvider: app.walletProvider,
                                    notesProvider: app.notesProvider,
                                    urlHelper: app.urlHelper)
        let viewController = TxDetailsViewController(viewModel: viewModel)
        viewController.backForBlur = back
        viewController.router = mainRouter
        viewController.cellY = cellY
        
        
        let balanceView = BillionBalanceView(frame: CGRect.zero)
        
        let currency = app.defaults.currencies.first!
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
