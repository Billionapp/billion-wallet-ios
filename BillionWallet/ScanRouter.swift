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
    private weak var mainRouter: MainRouter?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    // MARK: - Start routing
    func run() {
        guard let router = mainRouter else { return }
        
        // MARK: Inject dependencies or address only from mainRouter?.application to viewModel
        let viewModel = ScanVM(provider: router.application.scannerProvider)
        let scanViewController = ScanViewController(viewModel: viewModel)
        mainRouter?.navigationController.push(viewController: scanViewController)
    }
}
