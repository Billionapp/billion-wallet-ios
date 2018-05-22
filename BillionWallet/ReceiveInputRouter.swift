//
//  ReceiveInputRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ReceiveInputRouter: Router {

    private let mainRouter: MainRouter
    private let app: Application
    private let contact: PaymentCodeContactProtocol
    private let back: UIImage?

    init(mainRouter: MainRouter, application: Application, contact: PaymentCodeContactProtocol, back: UIImage?) {
        self.mainRouter = mainRouter
        self.app = application
        self.contact = contact
        self.back = back
    }

    func run() {
        let viewModel = ReceiveInputVM(contact: contact,
                                       ratesProvider: app.ratesProvider,
                                       defaultsProvider: app.defaults,
                                       walletProvider: app.walletProvider,
                                       lockProvider: app.lockProvider,
                                       contactsProvider: app.contactsProvider,
                                       messageSendProvider: app.messageSendProvider)

        let viewController = ReceiveInputViewController(viewModel: viewModel)
        viewController.mainRouter = mainRouter
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
