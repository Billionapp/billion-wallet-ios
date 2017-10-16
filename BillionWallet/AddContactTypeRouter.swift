//
//  AddContactTypeRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddContactTypeRouter: Router {
    
    private weak var mainRouter: MainRouter?
    
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    func run() {
        guard let router = mainRouter else { return }
        let viewModel = AddContactTypeVM(scanProvider: router.application.scannerProvider)
        let viewController = AddContactTypeViewController(viewModel: viewModel)
        viewController.router = router
        router.navigationController.push(viewController: viewController)
    }
}
