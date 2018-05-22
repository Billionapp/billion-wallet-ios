//
//  OnboardRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class OnboardRouter: Router {
    private let mainRouter: MainRouter
    private let app: Application
    
    init(mainRouter: MainRouter, app: Application) {
        self.mainRouter = mainRouter
        self.app = app
    }
    
    func run() {
        let viewModel = OnboardVM(defaultsProvider: app.defaults,
                                  accountProvider: app.accountProvider,
                                  contactsProvider: app.contactsProvider,
                                  failureTxProvider: app.failureTxProvider,
                                  userPaymentRequestProvider: app.userPaymentRequestProvider,
                                  selfPaymentRequestProvider: app.selfPaymentRequestProvider)
        let viewController = OnboardViewController.init(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.setViewControllers([viewController], animated: false)
    }
}
