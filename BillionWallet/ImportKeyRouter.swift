//
//  ImportKeyRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

final class ImportKeyRouter: Router {
    
    // MARK: - Private
    weak var mainRouter: MainRouter?
    
    // MARK: - Lifecycle
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    // MARK: - Start routing
    func run() {
        guard mainRouter != nil else { return }
        
        // MARK: Inject dependencies or address only from mainRouter?.application to viewModel
        let viewModel = ImportKeyVM(provider: (mainRouter?.application.scannerProvider)!, walletProvider:  (mainRouter?.application.walletProvider)!, txProvider: (mainRouter?.application.txProvider)!)
        let importKeyViewController = ImportKeyViewController(viewModel: viewModel)
        importKeyViewController.mainRouter = mainRouter
        mainRouter?.navigationController.push(viewController: importKeyViewController)
    }
}
