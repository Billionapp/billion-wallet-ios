//
//  ReceiveRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ReceiveRouter: Router {
    
    // MARK: - Private
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private let back: UIImage?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter, back: UIImage?, app: Application) {
        self.mainRouter = mainRouter
        self.back = back
        self.app = app
    }
    
    // MARK: - Start routing
    func run() {
        let viewModel = ReceiveVM(walletProvider: app.walletProvider,
                                  ratesProvider: app.ratesProvider,
                                  uriComposer: app.urlComposer,
                                  defaults: app.defaults)
        
        let receiveViewController = ReceiveViewController(viewModel: viewModel)
        receiveViewController.backImage = back
        receiveViewController.mainRouter = mainRouter
        mainRouter.navigationController.push(viewController: receiveViewController)
    }
}
