//
//  AuthChecker.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol AuthCheckerProtocol {
    func ensureAuthIsOk()
}

class AuthChecker: AuthCheckerProtocol {
    private let authProvider: AuthorizationProvider
    private let taskQProvider: TaskQueueProvider
    
    init(authProvider: AuthorizationProvider, taskQProvider: TaskQueueProvider) {
        self.authProvider = authProvider
        self.taskQProvider = taskQProvider
    }
    
    func ensureAuthIsOk() {
        authProvider.authenticate(completion: { result in
            switch result {
            case .success(let message):
                Logger.info(message)
            case .failure(let error):
                Logger.warn(error.localizedDescription)
                self.taskQProvider.addOperation(type: TaskQueue.OperationType.register)
            }
        })
    }
}
