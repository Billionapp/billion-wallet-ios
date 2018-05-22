//
//  SetupBioRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SetupBioRouter: Router {
    private let mainRouter: MainRouter
    private let defaults: Defaults
    private let keychain: Keychain
    private let iCloudProvider: ICloud
    
    init(mainRouter: MainRouter, defaults: Defaults, keychain: Keychain, iCloudProvider: ICloud) {
        self.mainRouter = mainRouter
        self.defaults = defaults
        self.keychain = keychain
        self.iCloudProvider = iCloudProvider
    }
    
    func run() {
        let viewModel = SetupBioVM(defaultsProvider: defaults, keychain: keychain, iCloudProvider: iCloudProvider)
        let viewController = SetupBioViewController.init(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.setViewControllers([viewController], animated: false)
    }
}
