//
//  ScanRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum ScanKey {
    case address
    case privateKey
}

final class ScanRouter: Router {
    
    // MARK: - Private
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private var qrResolver: QrResolver
    
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter, app: Application, qrResolver: QrResolver) {
        self.mainRouter = mainRouter
        self.app = app
        self.qrResolver = qrResolver
    }
    
    // MARK: - Start routing
    func run() {
        let viewModel = ScanVM(provider: app.scannerProvider,
                               accountProvider: app.accountProvider,
                               qrResolver: qrResolver)
        let scanViewController = ScanViewController(viewModel: viewModel)
        scanViewController.mainRouter = mainRouter
        mainRouter.navigationController.push(viewController: scanViewController)
    }
}
