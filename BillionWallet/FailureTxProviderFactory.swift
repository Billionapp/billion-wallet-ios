//
//  FailureTransactionProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol FailureTxProviderFactory {
    func createFailureTxProvider() -> FailureTxProtocol
}

class DefaultFailureTxProviderFactory: FailureTxProviderFactory {
    
    func createFailureTxProvider() -> FailureTxProtocol {
        let storageUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileManager = FileManager.default
        let storage = FailureTxAsyncStorage(fileManager: fileManager, storageUrl: storageUrl)
        let mapper = FailureTxMapper()
        let factory =  FailureTxFactory()
        
        return FailureTxProviderA(storage: storage,
                                  mapper: mapper,
                                  factory: factory)
    }
}
