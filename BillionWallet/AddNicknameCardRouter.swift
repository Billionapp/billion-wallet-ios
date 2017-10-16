//
//  AddNicknameCardRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddNicknameCardRouter: Router {
    
    let mainRouter: MainRouter
    let contact: UserData
    weak var contactsProvider: ContactsProvider?
    
    init(mainRouter: MainRouter, contact: UserData, contactsProvider: ContactsProvider?) {
        self.mainRouter = mainRouter
        self.contact = contact
        self.contactsProvider = contactsProvider
    }
    
    func run() {
        let viewModel =  AddNicknameCardVM(contact: contact, contactsProvider: contactsProvider)
        let viewController =  AddNicknameCardViewController(viewModel: viewModel)
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
