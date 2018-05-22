//
//  SetupCardRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SetupCardRouter: Router {
    private let mainRouter: MainRouter
    private let app: Application
    private let image: Data?
    private let name: String?
    
    init(mainRouter: MainRouter, app: Application, image: Data?, name: String?) {
        self.mainRouter = mainRouter
        self.app = app
        self.image = image
        self.name = name
    }
    
    func run() {
        let viewModel = SetupCardVM(api: app.api,
                                    icloudProvider: app.iCloud,
                                    accountProvider: app.accountProvider,
                                    taskQueueProvider: app.taskQueueProvider,
                                    defaults: app.defaults,
                                    avatarData: image,
                                    nameOld: name)
        let viewController = SetupCardViewController.init(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.setViewControllers([viewController], animated: false)
    }
}
