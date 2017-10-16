//
//  AddContactRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddContactNicknameRouter: Router {
    
    weak var mainRouter: MainRouter?
    
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    func run() {
        guard let router = mainRouter else {return}
        let viewModel = AddContactNicknameVM(apiProvider: router.application.api)
        let viewController = AddContactNicknameViewController(viewModel: viewModel)
        viewController.router = mainRouter
        router.navigationController.push(viewController: viewController)
    }
}
