//
//  BuyPickerRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BuyPickerRouter {

    let back: UIImage?
    let mainRouter: MainRouter

    init(mainRouter: MainRouter, back: UIImage?) {
        self.mainRouter = mainRouter
        self.back = back
    }

    func run(method: PaymentMethod?, methods: [String]?, output: BuyPickerOutputDelegate?) {
        let viewModel = BuyPickerVM(method: method, methods: methods, paymentMethodsFactory: PaymentMethodFactory(), output: output)
        let viewController = BuyPickerViewController(viewModel: viewModel)
        viewController.router = mainRouter
        viewController.backImage = back
        mainRouter.navigationController.push(viewController: viewController)
    }
}
