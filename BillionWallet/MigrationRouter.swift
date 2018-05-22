//
//  MigrationRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MigrationRouter: Router {

    private let mainRouter: MainRouter
    private let app: Application
    private let migrationManager: MigrationManagerProtocol

    init(mainRouter: MainRouter, app: Application, migrationManager: MigrationManagerProtocol) {
        self.mainRouter = mainRouter
        self.app = app
        self.migrationManager = migrationManager
    }

    func run() {
        let viewModel = MigrationVM(migrationManager: migrationManager)
        let viewController = MigrationViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
