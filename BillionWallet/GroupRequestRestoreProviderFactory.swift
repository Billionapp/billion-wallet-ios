//
//  GroupRequestRestoreProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupRequestRestoreProviderFactory {
    
    let requestProvider: UserPaymentRequestProtocol
    let selfRequestProvider: SelfPaymentRequestProtocol
    
    init(requestProvider: UserPaymentRequestProtocol, selfRequestProvider: SelfPaymentRequestProtocol) {
        self.requestProvider = requestProvider
        self.selfRequestProvider = selfRequestProvider
    }
    
    func create() -> GroupRequestRestoreProvider {
        let storage = GroupRequestStorageFactory(requestProvider: requestProvider).create()
        let requestStorage = MessageStorageManager(userPaymentRequestProvider: requestProvider, selfPaymentRequestProvider: selfRequestProvider)
        let provider = GroupRequestRestoreProvider(storage: storage, messageStorageManager: requestStorage, requestProvider: requestProvider, messageWrapper: MessageWrapper())
        return provider
    }

}
