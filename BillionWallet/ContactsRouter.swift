//
//  ContactsRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ContactsRouter: Router {
    
    let mainRouter: MainRouter
    let mode: ContactsVM.Mode
    weak var output: ContactsOutputDelegate?
    let back: UIImage
    
    init(mainRouter: MainRouter, output: ContactsOutputDelegate?, mode: ContactsVM.Mode, back: UIImage) {
        self.mainRouter = mainRouter
        self.output = output
        self.mode = mode
        self.back = back
    }
    
    func run() {
        let viewModel = ContactsVM(contactsProvider: ContactsProvider(), output: output, mode: mode)
        let viewController = ContactsViewController(viewModel: viewModel)
        viewController.backForBlur = back
        viewController.router = mainRouter
        mainRouter.navigationController.push(viewController: viewController)
    }
}
