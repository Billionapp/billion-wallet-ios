//
//  ChooseSenderRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ChooseSenderRouter: Router {

    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private let back: UIImage?
    private let conveyor: TouchConveyorView?

    init(mainRouter: MainRouter,
         app: Application,
         back: UIImage?,
         conveyor: TouchConveyorView?) {
        
        self.mainRouter = mainRouter
        self.app = app
        self.back = back
        self.conveyor = conveyor
    }

    func run() {
        let viewModel = ChooseSenderVM(contactsProvider: app.contactsProvider,
                                       walletProvider: app.walletProvider,
                                       tapticService: app.tapticService)
        let viewController = ChooseSenderViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = back
        viewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: viewController)
    }
}
