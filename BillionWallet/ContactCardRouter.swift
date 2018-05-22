//
//  ContactCardRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ContactCardRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private let backImage: UIImage
    private let contact: ContactProtocol
    private let urlComposer: URIComposer
    private let contactProvider: ContactsProvider
    private var apiProvider: API!
    
    init(mainRouter: MainRouter,
         contact: ContactProtocol,
         urlComposer: URIComposer,
         backImage: UIImage,
         contactProvider: ContactsProvider,
         apiProvider: API) {
        
        self.mainRouter = mainRouter
        self.contact = contact
        self.urlComposer = urlComposer
        self.backImage = backImage
        self.contactProvider = contactProvider
        self.apiProvider = apiProvider
    }
    
    func run() {
        let viewModel = ContactCardVM(contactProvider: contactProvider,
                                      contact: contact,
                                      urlComposer: urlComposer,
                                      apiProvider: apiProvider)
        let viewController = ContactCardViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = backImage
        mainRouter.navigationController.push(viewController: viewController)
    }
    
}
