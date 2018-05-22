//
//  UserPaymentRequestProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol UserPaymentRequestProviderFactory {
    func createUserPaymentRequestProvider() -> UserPaymentRequestProtocol
}

class DefaultUserPaymentRequestProviderFactory: UserPaymentRequestProviderFactory {
    
    func createUserPaymentRequestProvider() -> UserPaymentRequestProtocol {
        let storageUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileManager = FileManager.default
        let storage = UserPaymentRequestStorage(fileManager: fileManager, storageUrl: storageUrl)
        let mapper = UserPaymentRequestMapper()
        let factory =  UserPaymentRequestFactory()
        
        return UserPaymentRequestProvider(storage: storage,
                                          mapper: mapper,
                                          factory: factory)
    }
}
