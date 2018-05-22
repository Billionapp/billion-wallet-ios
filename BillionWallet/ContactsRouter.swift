//
//  ContactsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ContactsRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private let mode: ContactsVM.Mode
    private weak var output: ContactsOutputDelegate?
    private weak var app: Application!
    
    init(mainRouter: MainRouter, output: ContactsOutputDelegate?, mode: ContactsVM.Mode, app: Application) {
        self.mainRouter = mainRouter
        self.output = output
        self.mode = mode
        self.app = app
    }
    
    func run() {
        let viewModel = ContactsVM(contactsProvider: app.contactsProvider,
                                   output: output,
                                   mode: mode,
                                   scannerProvider: app.scannerProvider,
                                   tapticService: app.tapticService)
        let viewController = ContactsViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
