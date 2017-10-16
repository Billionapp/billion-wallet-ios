//
//  ContactCardRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ContactCardRouter: Router {
    
    private weak var mainRouter: MainRouter?
    
    let contact: ContactProtocol
    
    init(mainRouter: MainRouter, contact: ContactProtocol) {
        self.mainRouter = mainRouter
        self.contact = contact
    }
    
    func run() {
        let viewModel = ContactCardVM(contact: contact, contactsProvider: mainRouter?.application.contactsProvider)
        let viewController = ContactCardViewController(viewModel: viewModel)
        viewController.router = mainRouter
        if mainRouter?.navigationController.topViewController is AddContactTypeViewController {
            mainRouter?.navigationController.pop()
        }
        mainRouter?.navigationController.push(viewController: viewController)
    }
    
}
