//
//  SettingsRestoreRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsRestoreRouter: Router {
    
    let mainRouter: MainRouter
    let info: SettingsRestoreVM.Info
    let iCloudProvider: ICloud
    let defaultsProvider: Defaults
    let back: UIImage?
    
    init(mainRouter: MainRouter, info: SettingsRestoreVM.Info, icloudProvider: ICloud, defaultsProvider: Defaults, back: UIImage?) {
        self.mainRouter = mainRouter
        self.info = info
        self.iCloudProvider = icloudProvider
        self.defaultsProvider = defaultsProvider
        self.back = back
    }
    
    func run() {
        let viewModel = SettingsRestoreVM(info: info, accountProvider: AccountManager.shared, icloudProvider: iCloudProvider, defaultsProvider: defaultsProvider)
        let viewController = SettingsRestoreViewController(viewModel: viewModel)
        viewController.router = self
        viewController.backImage = back
        mainRouter.navigationController.push(viewController: viewController)
    }
    
    func runAsRoot() {
        let viewModel = SettingsRestoreVM(info: info, accountProvider: AccountManager.shared, icloudProvider: iCloudProvider, defaultsProvider: defaultsProvider)
        let viewController = SettingsRestoreViewController(viewModel: viewModel)
        viewController.router = self
        viewController.backImage = back
        mainRouter.navigationController.setViewControllers([viewController], animated: false)
    }
}
