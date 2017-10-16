//
//  LocalCrypto.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// This structure incapsulates CryptoSwift-free versions of ECIES configuration
struct LocalCrypto: ECIESConfigProvider {
    
    func genECIESConfig() -> ECIESConfig {
        let s1 = "PBKDF2 salt".data(using: .utf8)!
        let s2 = "HMAC salt".data(using: .utf8)!
        return ECIESConfig(
            S1: s1,
            S2: s2,
            cypherEncrypt: aes256.encrypt,
            cypherDecrypt: aes256.decrypt,
            KDF: pbkdf2.deriveKey,
            MAC: hmac.sha512
        )
    }
}
