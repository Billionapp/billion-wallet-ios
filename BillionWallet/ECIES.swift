//
//  ECIES.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// This class encapsulates logic of ECIES
/// Encryption scheme is described in article https://en.wikipedia.org/wiki/Integrated_Encryption_Scheme
class ECIES {
    
    /// Scheme parameters
    var config: ECIESConfig?
    
    /// Message encryption key
    var Ke: Data?
    /// Message signature key
    var Km: Data?
    
    // FIXME: Do we need this?
    init() { }
    
    /// Scheme initialization with parameters and pre-generated keys. Useful when using keys cache.
    ///
    /// - Parameters:
    ///   - ke: Encryption key
    ///   - km: Signature key
    ///   - config: Scheme parameters
    init(ke: Data, km: Data, config: ECIESConfig) {
        self.config = config
        Ke = ke
        Km = km
    }
    
    /// Scheme initialization with given parameters
    ///
    /// - Parameter configuration: Scheme parameters
    init(with configuration: ECIESConfig) {
        self.config = configuration
    }
    
    /// Gen secret point
    ///
    /// - Parameters:
    ///   - a: EC point (public key)
    ///   - b: Private key
    /// - Returns: A secret point
    fileprivate func calcSecretPoint(pub a: ECPointS, priv b: UInt256S) -> ECPointS {
        let result = Secp256k1.pointMul(a.ecpoint, mul: b.uint256)
        return ECPointS(result)
    }
    
    /// Derive encryption and signature keys from entropy bytes. Warning! CPU-time consuming operation.
    ///
    /// - Parameters:
    ///   - entropy: secret bytes
    ///   - salt: salt
    /// - Returns: (Ke - encryption key, Km - signature key)
    fileprivate func deriveKeys(_ entropy: Data, salt: Data) -> (Ke: Data, Km: Data)? {
        let Kem = config!.KDF(entropy, salt)
        let len = Kem.count
        guard len % 2 == 0 else { return nil }
        let halflen = len/2
        let Ke = Kem.subdata(in: 0..<halflen)
        let Km = Kem.subdata(in: halflen..<len)
        
        return (Ke: Ke, Km: Km)
    }
    
    /// Encrypt message with generated key
    ///
    /// - Parameter message: Message
    /// - Returns: Ciphertext
    fileprivate func encryptMessage(_ message: Data) -> Data {
        return config!.cypherEncrypt(message, Ke!)
    }
    
    /// Decrypt message with generated key
    ///
    /// - Parameter cypher: Ciphertext
    /// - Returns: Decrypted message
    fileprivate func decryptMessage(_ cypher: Data) -> Data {
        return config!.cypherDecrypt(cypher, Ke!)
    }
    
    /// Create ciphertext MAC signature. Do not pass plain message as a parameter.
    ///
    /// - Parameter cypher: Ciphertext
    /// - Returns: Ciphertext signature
    fileprivate func createMac(_ cypher: Data) -> Data {
        var cypherData = Data()
        cypherData.append(cypher)
        cypherData.append(config!.S2)
        let mac = config!.MAC(cypherData, Km!)
        return mac
    }
    
    /// Check ciphertext signature
    ///
    /// - Parameters:
    ///   - cypher: Ciphertext
    ///   - mac: MAC signature
    /// - Returns: Check result
    fileprivate func checkMac(_ cypher: Data, mac: Data) -> Bool {
        let computedMac = createMac(cypher)
        return computedMac == mac
    }
    
    /// Pregenerate keys before encryption-decryption routines
    ///
    /// - Parameters:
    ///   - a: A's private key
    ///   - b: B's public key
    func setUp(priv a: UInt256S, pub b: ECPointS) {
        let S = calcSecretPoint(pub: b, priv: a)
        let keys = deriveKeys(S.data, salt: config!.S1)
        Ke = keys!.Ke
        Km = keys!.Km
    }
    
    /// Encrypt message
    ///
    /// - Parameter message: Message data
    /// - Returns: (c - ciphertext, d - mac signature)
    func encrypt(_ message: Data) -> (c: Data, d: Data) {
        let cypher = encryptMessage(message)
        let mac = createMac(cypher)
        return (c: cypher, d: mac)
    }
    
    /// Decrypt message
    ///
    /// - Parameters:
    ///   - cypher: Ciphertext
    ///   - mac: MAC signature
    /// - Returns: Decrypted Message, nil if signature is not valid
    func decrypt(_ cypher: Data, mac: Data) -> Data? {
        guard checkMac(cypher, mac: mac) else { return nil }
        let message = decryptMessage(cypher)
        return message
    }
    
    /// Get pubkey with given private (order secp256k1)
    ///
    /// - Parameter priv: Private key
    /// - Returns: Public key
    static func privToPub(_ priv: UInt256S) -> ECPointS {
        // FIXME: do we need this method?
        let point = Secp256k1.pointGen(priv.uint256)
        return ECPointS(point)
    }
}
