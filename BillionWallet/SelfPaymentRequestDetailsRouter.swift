//
//  SelfPaymentRequestDetailsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SelfPaymentRequestDetailsRouter: Router {

    private let mainRouter: MainRouter
    private let app: Application
    private let displayer: SelfPaymentRequestDisplayer
    private let back: UIImage?
    private let cellY: CGFloat

    init(mainRouter: MainRouter,
         application: Application,
         displayer: SelfPaymentRequestDisplayer,
         back: UIImage?,
         cellY: CGFloat) {
        
        self.mainRouter = mainRouter
        self.app = application
        self.displayer = displayer
        self.back = back
        self.cellY = cellY
    }

    func run() {
        let viewModel = SelfPRDetailsVM(displayer: displayer,
                                        walletProvider: app.walletProvider,
                                        selfPaymentRequestProvider: app.selfPaymentRequestProvider,
                                        fiatConverter: app.fiatConverter,
                                        cellY: cellY,
                                        messageSendProvider: app.messageSendProvider)
        let viewController = SelfPaymentRequestDetailsViewController(viewModel: viewModel)
        viewController.backImage = back
        viewController.router = mainRouter
        
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
