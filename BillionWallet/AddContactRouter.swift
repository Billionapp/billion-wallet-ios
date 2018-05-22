//
//  AddContactRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddContactRouter: Router {

    let mainRouter: MainRouter
    let backImage: UIImage
    weak var addContactProvider: AddContactProvider!
    weak var contactsProvider: ContactsProvider!
    private weak var app: Application!

    init(mainRouter: MainRouter,
         app: Application,
         addContactProvider: AddContactProvider,
         contactsProvider: ContactsProvider,
         back: UIImage) {
        
        self.mainRouter = mainRouter
        self.addContactProvider = addContactProvider
        self.contactsProvider = contactsProvider
        self.backImage = back
        self.app = app
    }

    func run() {
        let viewModel = AddContactVM(addContactProvider: addContactProvider, contactsProvider: contactsProvider)
        
        let pcResolver = PaymentCodeResolver(accountProvider: app.accountProvider, callback: viewModel.pcHandler)
        let pcFailResolver = PCFailResolver()

        pcResolver.chain(pcFailResolver)
        viewModel.setResolver(pcResolver)
        
        let viewController = AddContactViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage =  backImage
        mainRouter.navigationController.push(viewController: viewController)
    }
    
}
