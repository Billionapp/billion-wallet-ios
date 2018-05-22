//
//  Crypto.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

func invokeUnsafeMethod<T1, T2, Result>(_ method: @escaping (UnsafeMutablePointer<T1>, UnsafePointer<T2>) -> Result, arg1: inout T1, arg2: T2) -> Result {
    var arg2 = arg2
    return withUnsafeMutablePointer(to: &arg1) { (arg1_p) -> Result in
        return withUnsafePointer(to: &arg2, { (arg2_p) -> Result in
            return method(arg1_p, arg2_p)
        })
    }
}

func invokeUnsafeMethod<T1, T2, Result>(_ method: @escaping (UnsafeMutablePointer<T1>, UnsafeMutablePointer<T2>) -> Result, arg1: inout T1, arg2: inout T2) -> Result {
    var arg2_masked = arg2
    let result = withUnsafeMutablePointer(to: &arg1) { (arg1_p) -> Result in
        let result = withUnsafeMutablePointer(to: &arg2_masked, { (arg2_p) -> Result in
            return method(arg1_p, arg2_p)
        })
        return result
    }
    arg2 = arg2_masked
    return result
}

/// Default cryptographic primitives used in ECIES
class Crypto {
    
    /// Generate random bytes
    struct Random {
        // TODO: Make an ObjC Class, using secure allocator for this bytes?
        static func data(_ len: Int) -> Data {
            let buf = UnsafeMutableRawPointer.allocate(bytes: len, alignedTo: 1)
            arc4random_buf(buf, len)
            let randomData = Data(bytes: buf, count: len)
            buf.deallocate(bytes: len, alignedTo: 1)
            
            return randomData
        }
        
        static func uInt256S() -> UInt256S {
            let buf = UnsafeMutableRawPointer.allocate(bytes: 32, alignedTo: 1)
            arc4random_buf(buf, 32)
            let randomKeyData = Data(bytes: buf, count: 32)
            buf.deallocate(bytes: 32, alignedTo: 1)
            return UInt256S(data: randomKeyData)
        }
    }
    
    /// Encrypt message. AES256 in CBC Mode with PKCS#7 padding.
    /// Using hax to not transfer IV along with ciphertext.
    /// 
    /// - Parameters:
    ///   - message: Message
    ///   - key: Encryption key
    /// - Returns: Ciphertext
    static func encrypt(message: Data, key: Data) throws -> Data {
        // IV = [0], mode = CBC, padding = PKCS7
        let aes = try CryptoSwift.AES(key: key.bytes)
        
        // imlicitly set random IV
        var expandedMessage = Data()
        expandedMessage.append(Random.data(AES.blockSize))
        expandedMessage.append(message)
        let cypher = try aes.encrypt(expandedMessage)
        return Data(cypher)
    }
    
    /// Message decryption. AES256 in CBC Mode with PKCS#7 padding.
    ///
    /// - Parameters:
    ///   - cypher: Ciphertext
    ///   - key: Encryption key
    /// - Returns: Decrypted message
    static func decrypt(cypher: Data, key: Data) throws -> Data {
        // IV = [0], mode = CBC, padding = PKCS7
        let aes = try AES(key: key.bytes)
        let expandedMessage = try aes.decrypt(cypher)
        
        // drop implicit random IV
        let message = Data(expandedMessage).suffix(from: AES.blockSize)
        return Data(message)
    }
    
    /// Key derivation function. PBKDF2 with HMAC-SHA512 as PRF
    ///
    /// - Parameters:
    ///   - entropy: Random bytes
    ///   - salt: Salt
    /// - Returns: Derived key
    static func KDF(entropy: Data, salt: Data) throws -> Data {
        let pbkdf2 = try PKCS5.PBKDF2(password: entropy.bytes, salt: salt.bytes, iterations: 4096, variant: CryptoSwift.HMAC.Variant.sha512)
        let key = try pbkdf2.calculate()
        return Data(key)
    }
    
    /// MAC function. HMAC-SHA512
    ///
    /// - Parameters:
    ///   - message: Message
    ///   - key: Signature key
    /// - Returns: Message signature
    static func MAC(message: Data, key: Data) throws -> Data {
        let hmac = CryptoSwift.HMAC(key: key.bytes, variant: CryptoSwift.HMAC.Variant.sha512)
        let mac = try hmac.authenticate(message.bytes)
        return Data(mac)
    }
}
