//
//  PasscodeRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PasscodeRouter: Router {
    
    let mainRouter: MainRouter
    let passcodeCase: PasscodeCase!
    weak var lockDelegate: LockDelegate?
    weak var output: PasscodeOutputDelegate?
    
    init(mainRouter: MainRouter, passcodeCase: PasscodeCase, output: PasscodeOutputDelegate?, lockDelegate: LockDelegate) {
        self.mainRouter = mainRouter
        self.passcodeCase = passcodeCase
        self.output = output
        self.lockDelegate = lockDelegate
    }
    
    func run() {
        let viewModel = PasscodeVM(touchIdProvider: mainRouter.application.touchId, passcodeCase: passcodeCase, output: output)
        viewModel.lockListener = lockDelegate
        let viewController = PasscodeViewController(viewModel: viewModel)
        viewModel.delegate = viewController
        viewController.router = mainRouter
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        mainRouter.navigationController.modal(viewController: viewController)
    }
}
