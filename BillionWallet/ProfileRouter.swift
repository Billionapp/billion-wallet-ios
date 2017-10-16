//
//  ProfileRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class  ProfileRouter: Router {
    
    let mainRouter: MainRouter
    let back: UIImage
    
    init(mainRouter: MainRouter, back: UIImage) {
        self.mainRouter = mainRouter
        self.back = back
    }
    
    func run() {
        let viewModel = ProfileVM(api: mainRouter.application.api, icloudProvider: mainRouter.application.iCloud, defaults: mainRouter.application.defaults)
        let viewController =  ProfileViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backForBlur = back
        mainRouter.navigationController.push(viewController: viewController)
    }
}
