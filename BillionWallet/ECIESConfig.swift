//
//  ECIESConfig.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum ECIESConfigIdentifier: String {
    case cryptoSwift = "CryptoSwift"
    case localCrypto = "LocalCrypto"
}

/// Configuration for ECIES
struct ECIESConfig {
    var identifier: ECIESConfigIdentifier
    /// Salt for KDF, may be empty
    var S1: Data
    /// Salt for MAC function, may be empty
    var S2: Data
    /// Encryption function
    var cypherEncrypt: (_ message: Data, _ key: Data) throws -> Data
    /// Decryption function
    var cypherDecrypt: (_ cyphertext: Data, _ key: Data) throws -> Data
    /// Key Derivation Function
    var KDF: (_ entropy: Data, _ salt: Data) throws -> Data
    /// Message Auth function
    var MAC: (_ message: Data, _ key: Data) throws -> Data
}
