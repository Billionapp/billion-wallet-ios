//
//  PrivacyRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 4/10/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PrivacyRouter: Router {

    private let mainRouter: MainRouter

    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }

    func run() {
        let viewModel = PrivacyVM()
        let viewController = PrivacyViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
