//
//  ChooseReceiverRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ChooseReceiverRouter {
    // MARK: - Private
    private let mainRouter: MainRouter
    private let app: Application
    private let back: UIImage
    private let conveyor: TouchConveyorView?

    // MARK: - Lifecycle
    init(mainRouter: MainRouter, application: Application, back: UIImage, conveyor: TouchConveyorView?) {
        self.mainRouter = mainRouter
        self.app = application
        self.back = back
        self.conveyor = conveyor
    }

    // MARK: - Start routing
    func run() {
        let viewModel = ChooseReceiverVM(contactsProvider: app.contactsProvider,
                                         apiProvider: app.api,
                                         tapticService: app.tapticService)
        

        let addressResolver = AddressResolver(callback: viewModel.addressHandler, walletProvider: app.walletProvider)
        let pcResolver = PaymentCodeResolver(accountProvider: app.accountProvider,
                                             callback: viewModel.pcHandler)
        
        addressResolver.chain(pcResolver)
        viewModel.setResolver(addressResolver)
        
        let chooseReceiverViewController = ChooseReceiverViewController(viewModel: viewModel)
        chooseReceiverViewController.mainRouter = mainRouter
        chooseReceiverViewController.backImage = back
        chooseReceiverViewController.conveyorView = conveyor
        mainRouter.navigationController.push(viewController: chooseReceiverViewController)
    }
}
