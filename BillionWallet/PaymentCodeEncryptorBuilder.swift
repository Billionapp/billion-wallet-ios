//
//  PaymentCodeEncryptorBuilder.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol PaymentCodeEncryptorBuilder {
    func buildPCEncryptor(forPC pc: PaymentCode) -> PaymentCodeEncryptor
}

class PCEncryptorBuilder: PaymentCodeEncryptorBuilder {
    private let selfPC: PrivatePaymentCode
    private let cache: PCKeyCacheService
    private let config: ECIESConfig
    
    init(selfPC: PrivatePaymentCode, cache: PCKeyCacheService, config: ECIESConfig) {
        self.selfPC = selfPC
        self.cache = cache
        self.config = config
    }
    
    func buildPCEncryptor(forPC pc: PaymentCode) -> PaymentCodeEncryptor {
        return PaymentCodeEncryptor(selfPC, pc, cache: cache, config: config)
    }
}
