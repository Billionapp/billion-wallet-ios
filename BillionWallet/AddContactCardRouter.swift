//
//  AddContactCardRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddContactCardRouter: Router {

    private weak var mainRouter: MainRouter!
    private let backImage: UIImage
    private let contact: ContactProtocol
    private let contactsProvider: ContactsProvider
    private let transactionLinker: TransactionLinkerProtocol
    private let transactionRelator: TransactionRelatorProtocol
    private let paymentCodesProvider: PaymentCodesProvider
    
    init(mainRouter: MainRouter,
         contact: ContactProtocol,
         backImage: UIImage,
         contactsProvider: ContactsProvider,
         transactionLinker: TransactionLinkerProtocol,
         transactionRelator: TransactionRelatorProtocol,
         paymentCodesProvider: PaymentCodesProvider) {
        
        self.mainRouter = mainRouter
        self.contact = contact
        self.backImage = backImage
        self.contactsProvider = contactsProvider
        self.transactionLinker = transactionLinker
        self.transactionRelator = transactionRelator
        self.paymentCodesProvider = paymentCodesProvider
    }

    func run() {
        let viewModel = AddContactCardVM(contact: contact,
                                         contactsProvider: contactsProvider,
                                         transactionLinker: transactionLinker,
                                         transactionRelator: transactionRelator,
                                         paymentCodesProvider: paymentCodesProvider)
        
        let viewController = AddContactCardViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = backImage
        mainRouter.navigationController.push(viewController: viewController)
    }
}
