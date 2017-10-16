//
//  AddContactAddressRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddContactAddressRouter: Router {
    
    // MARK: - Private
    weak var mainRouter: MainRouter?
    let address: String
    let txHash: UInt256S?
    
    init(mainRouter: MainRouter, address: String, txHash: UInt256S?) {
        self.mainRouter = mainRouter
        self.address = address
        self.txHash = txHash
    }
    
    func run() {
        guard let mainRouter = mainRouter else { return }
        
        let viewModel = AddContactAddressVM(contactsProvider: mainRouter.application.contactsProvider, icloudProvider: mainRouter.application.iCloud, address: address, txHash: txHash)
        let viewController = AddContactAddressViewController(viewModel: viewModel)
        viewController.router = mainRouter
        if mainRouter.navigationController.topViewController is AddContactTypeViewController {
            mainRouter.navigationController.popQuickly()
            mainRouter.navigationController.push(viewController: viewController)
        } else {
            mainRouter.navigationController.push(viewController: viewController)
        }
    }
}
