//
//  PasscodeRouter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PasscodeRouter {
    
    private weak var mainRouter: MainRouter!
    private let passcodeCase: PasscodeCase
    private let reason: String?
    private var output: PasscodeOutputDelegate?
    private weak var app: Application!
    
    init(mainRouter: MainRouter,
         passcodeCase: PasscodeCase,
         output: PasscodeOutputDelegate?,
         app: Application,
         reason: String?) {
        
        self.mainRouter = mainRouter
        self.passcodeCase = passcodeCase
        self.output = output
        self.app = app
        self.reason = reason
    }
    
    func run(pinSize: Int = 6) {
        let viewModel = UniversalPinVM(touchIdProvider: app.touchId,
                                       passcodeCase: passcodeCase,
                                       output: output,
                                       lockProvider: app.lockProvider,
                                       reason: reason,
                                       pinSize: pinSize)
        
        let viewController = PasscodeViewController(viewModel: viewModel)
        viewModel.delegate = viewController
        viewController.router = mainRouter
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        viewModel.showTouchIdIfNeeded(withFallback: {
            self.mainRouter.navigationController.modal(viewController: viewController)
        })
    }
    
    func run(pinSize: Int, output: PasscodeOutputDelegate) {
        let viewModel = UniversalPinVM(touchIdProvider: app.touchId,
                                       passcodeCase: passcodeCase,
                                       output: output,
                                       lockProvider: app.lockProvider,
                                       reason: reason,
                                       pinSize: pinSize)
        
        let viewController = PasscodeViewController(viewModel: viewModel)
        viewModel.delegate = viewController
        viewController.router = mainRouter
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        viewModel.showTouchIdIfNeeded(withFallback: {
            self.mainRouter.navigationController.modal(viewController: viewController)
        })
    }
    
}
