//
//  PaymentRequestDetailsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PaymentRequestDetailsRouter: Router {

    private let mainRouter: MainRouter
    private let app: Application
    private let displayer: UserPaymentRequestDisplayer
    private let back: UIImage?
    private let cellY: CGFloat

    init(mainRouter: MainRouter,
         application: Application,
         displayer: UserPaymentRequestDisplayer,
         back: UIImage?,
         cellY: CGFloat) {
        
        self.mainRouter = mainRouter
        self.app = application
        self.displayer = displayer
        self.back = back
        self.cellY = cellY
    }

    func run() {
        var maxSendAmountBuilder: MaxSendAmountBuilder!
        if let contact = displayer.connection as? PaymentCodeContactProtocol {
            maxSendAmountBuilder = PCMaxAmountBuilder(walletProvider: app.walletProvider,
                                                    contact: contact,
                                                    feeProvider: app.feeProvider,
                                                    notificationSizeApproximizer: NotificationV1TxSizeApproximizer(),
                                                    regularSizeApproximizer: StandardTxSizeApproximizer())
        } else {
            maxSendAmountBuilder = AddressMaxAmountBuilder(walletProvider: app.walletProvider,
                                                           feeProvider: app.feeProvider,
                                                           sizeApproximizer: StandardTxSizeApproximizer())
        }

        let viewModel = PaymentRequestDetailsVM(maxSendAmountBuilder: maxSendAmountBuilder,
                                                displayer: displayer,
                                                walletProvider: app.walletProvider,
                                                userPaymentRequestProvider: app.userPaymentRequestProvider,
                                                fiatConverter: app.fiatConverter,
                                                messageSendProvider: app.messageSendProvider,
                                                cellY: cellY)


        let viewController = PaymentRequestDetailsViewController(viewModel: viewModel)
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
