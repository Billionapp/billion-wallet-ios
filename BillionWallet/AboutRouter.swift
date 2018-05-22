//
//  AboutRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 3/19/18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AboutRouter: Router {

    private let mainRouter: MainRouter

    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }

    func run() {
        let viewModel = AboutVM()
        let viewController = AboutViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.setViewControllers([viewController], animated: false)
    }
}
