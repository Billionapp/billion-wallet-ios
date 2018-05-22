//
//  SettingsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsRouter: Router {
    
    private weak var app: Application!
    private weak var mainRouter: MainRouter!
    private let back: UIImage
    
    init(application: Application, mainRouter: MainRouter, back: UIImage) {
        self.app = application
        self.mainRouter = mainRouter
        self.back = back
    }
    
    func run() {
        let viewModel = SettingsVM(network: app.network,
                                   defaultsProvider: app.defaults,
                                   keychain: app.keychain,
                                   lockProvider: app.lockProvider,
                                   iCloudProvider: app.iCloud,
                                   accountProvider: app.accountProvider,
                                   walletProvider: app.walletProvider,
                                   ratesProvider: app.ratesProvider,
                                   feeProvider: app.feeProvider,
                                   tastQueue: app.taskQueueProvider,
                                   failureTxProvider: app.failureTxProvider,
                                   contactsProvider: app.contactsProvider,
                                   messageFetchProvider: app.messageFetchProvider,
                                   userPaymentRequestProvider: app.userPaymentRequestProvider,
                                   selfPaymentRequestProvider: app.selfPaymentRequestProvider,
                                   rateQ: app.rateQ)

        let viewController = SettingsViewController(viewModel: viewModel)
        viewController.backImage = back
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }


}
