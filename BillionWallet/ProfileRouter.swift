//
//  ProfileRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class  ProfileRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private let back: UIImage
    
    init(mainRouter: MainRouter, app: Application, back: UIImage) {
        self.mainRouter = mainRouter
        self.app = app
        self.back = back
    }
    
    func run() {
        let viewModel = ProfileVM(api: app.api, icloudProvider: app.iCloud, defaults: app.defaults, accountProvider: app.accountProvider)
        let viewController =  ProfileViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = back
        mainRouter.navigationController.push(viewController: viewController)
    }
}
