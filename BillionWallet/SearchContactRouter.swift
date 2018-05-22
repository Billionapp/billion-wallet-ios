//
//  SearchContactRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SearchContactRouter: Router {
    
    private weak var mainRouter: MainRouter!
    private weak var app: Application!
    private let billionCode: String
    private let backImage: UIImage
    
    init(mainRouter: MainRouter,
         app: Application,
         billionCode: String,
         backImage: UIImage) {
        
        self.mainRouter = mainRouter
        self.app = app
        self.backImage = backImage
        self.billionCode = billionCode
    }
    
    func run() {
        let viewModel = SearchContactVM(billionCode: billionCode, apiProvider: app.api, contactsProvider: app.contactsProvider)
        let viewController = SearchContactViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = backImage
        mainRouter.navigationController.push(viewController: viewController)
    }
}
