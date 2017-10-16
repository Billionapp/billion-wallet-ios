//
//  ECIESConfig.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// Configuration for ECIES
struct ECIESConfig {
    /// Salt for KDF, may be empty
    var S1: Data
    /// Salt for MAC function, may be empty
    var S2: Data
    /// Encryption function
    var cypherEncrypt: (_ message: Data, _ key: Data) -> Data
    /// Decryption function
    var cypherDecrypt: (_ cyphertext: Data, _ key: Data) -> Data
    /// Key Derivation Function
    var KDF: (_ entropy: Data, _ salt: Data) -> Data
    /// Message Auth function
    var MAC: (_ message: Data, _ key: Data) -> Data
}
