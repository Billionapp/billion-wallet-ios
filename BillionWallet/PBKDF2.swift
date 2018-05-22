//
//  PBKDF2.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

fileprivate extension Data {
    var rawBytes: UnsafeRawPointer {
        return self.withUnsafeBytes { UnsafeRawPointer($0) }
    }
}

extension LocalCrypto {
    
    /// Key derivation function. Bread C variant.
    struct pbkdf2 {
        static func deriveKey(_ entropy: Data, salt saltData: Data) throws -> Data {
            let derivedKeySize = 512/8
            
            let dk = UnsafeMutableRawPointer.allocate(bytes: derivedKeySize, alignedTo: 1)
            let pw = entropy.rawBytes
            let salt = saltData.rawBytes
            PBKDF2(dk, derivedKeySize, SHA512, 512/8, pw, entropy.count, salt, saltData.count, 4096)
            
            let derivedKey = Data(bytes: dk, count: derivedKeySize)
            dk.deallocate(bytes: derivedKeySize, alignedTo: 1)
            return derivedKey
        }
    }
}
