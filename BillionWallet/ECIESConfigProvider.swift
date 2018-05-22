//
//  ECIESConfigProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation


/// ECIESConfig generator protocol
protocol ECIESConfigProvider {
    /// Default config
    ///
    /// - Returns: Default ecies config
    func genECIESConfig() -> ECIESConfig
    /// Specific config
    ///
    /// - Parameter identifier: identifier of a config
    /// - Returns: Requested config of default one
    func genECIESConfig(identifier: ECIESConfigIdentifier) -> ECIESConfig
    /// Specific config with custom salt data
    ///
    /// - Parameters:
    ///   - identifier: identifier of a config
    ///   - salt1: kdf salt
    ///   - salt2: mac salt
    /// - Returns: Requested config or default one with custom salts
    func genECIESConfig(identifier: ECIESConfigIdentifier, _ salt1: Data?, _ salt2: Data?) -> ECIESConfig
}

extension ECIESConfigProvider {
    func genECIESConfig() -> ECIESConfig {
        return genECIESConfig(identifier: .cryptoSwift)
    }
    
    func genECIESConfig(identifier: ECIESConfigIdentifier, _ salt1: Data? = nil, _ salt2: Data? = nil) -> ECIESConfig {
        var config = genECIESConfig(identifier: identifier)
        if let salt1 = salt1 {
            config.S1 = salt1
        }
        if let salt2 = salt2 {
            config.S2 = salt2
        }
        return config
    }
}

class ECIESConfigFactory: ECIESConfigProvider {
    func genECIESConfig(identifier: ECIESConfigIdentifier) -> ECIESConfig {
        let s1 = "PBKDF2 salt".data(using: .utf8)!
        let s2 = "HMAC salt".data(using: .utf8)!
        switch identifier {
        case .localCrypto:
            return ECIESConfig(
                identifier: .localCrypto,
                S1: s1,
                S2: s2,
                cypherEncrypt: LocalCrypto.aes256.encrypt,
                cypherDecrypt: LocalCrypto.aes256.decrypt,
                KDF: LocalCrypto.pbkdf2.deriveKey,
                MAC: LocalCrypto.hmac.sha512
            )
        default: // case .cryptoSwift:
            return ECIESConfig(
                identifier: .cryptoSwift,
                S1: s1,
                S2: s2,
                cypherEncrypt: Crypto.encrypt,
                cypherDecrypt: Crypto.decrypt,
                KDF: Crypto.KDF,
                MAC: Crypto.MAC
            )
        }
    }
}
