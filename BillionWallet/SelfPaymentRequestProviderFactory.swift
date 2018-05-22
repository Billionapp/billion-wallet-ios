//
//  SelfPaymentRequestProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol SelfPaymentRequestProviderFactory {
    func createSelfPaymentRequestProvider() -> SelfPaymentRequestProtocol
}

class DefaultSelfPaymentRequestProviderFactory: SelfPaymentRequestProviderFactory {
    
    func createSelfPaymentRequestProvider() -> SelfPaymentRequestProtocol {
        let storageUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        let fileManager = FileManager.default
        let storage = SelfPaymentRequestStorage(fileManager: fileManager, storageUrl: storageUrl)
        let mapper = SelfPaymentRequestMapper()
        let factory =  SelfPaymentRequestFactory()
        
        return SelfPaymentRequestProvider(storage: storage,
                                          mapper: mapper,
                                          factory: factory)
    }
}
