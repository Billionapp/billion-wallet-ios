//
//  BIP47.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

typealias Pub = ECPointS
typealias Priv = UInt256S

/// Implementation of calculation functions used in BIP47 DH address exchange
struct BIP47 {
    /// Extract x value from short public key representation
    ///
    /// - Parameter pub: Public key
    /// - Returns: x vaue of pub
    static func xFromPub(_ pub: Pub) -> UInt256S {
        let xSign = pub.data
        let xData = xSign.subdata(in: Range<Int>(1..<xSign.count))
        return UInt256S(data: xData)
    }

    /// Calculates the blinding factor sutable to mask/unmask
    /// payment code for/from notification transaction.
    ///
    /// s = HMAC-SHA512(Sx, o)
    ///
    /// - Parameters:
    ///   - secretPoint: secret point S = bA = aB = abG
    ///   - outpoint: notification transaction outpoint, existent or planning
    /// - Returns: 512 bit of blinding factor in form of XPriv
    static func blindingFactor(_ secretPoint: Pub, outpoint: TXOutpointS) throws -> XPriv {
        let x = xFromPub(secretPoint)
        let xData = x.data
        let oData = outpoint.data
        let hmac = try HMAC(key: oData.bytes, variant: .sha512).authenticate(xData.bytes)
        return try XPriv(hmac)
    }
    
    /// Calculates secret point S = aB = Ab
    ///
    /// - Parameters:
    ///   - a: private key (owner's part)
    ///   - b: public key (pal's part)
    /// - Returns: The secret point S
    static func secretPoint(priv a: Priv, pub b: Pub) -> Pub {
        let point = Secp256k1.pointMul(b.ecpoint, mul: a.uint256)
        return Pub(point)
    }

    /// Calculates scalar shared secret interpreted as private key
    ///
    /// s = SHA256(Sx)
    ///
    /// - Parameter secretPoint: The secret point S
    /// - Returns: Scalar shared secret s, nil if point is not in secp256k1 group (1/2^128 probability)
    static func scalarSharedSecret(_ secretPoint: Pub) -> Priv? {
        let x = xFromPub(secretPoint)
        let hashData = x.data.sha256()
        let hash = Priv(data: hashData)
        guard Secp256k1.isPoint(inGroup: hash.uint256) else { return nil }
        return hash
    }
    
    /// Generate ephemeral public key B' using shared secret s and public key B.
    /// B' is sutable for sending btcs in private manner.
    ///
    /// - Parameters:
    ///   - sharedSecret: shared secret s
    ///   - pub: public key B
    /// - Returns: ephemeral public key B'
    static func ephemeralPubKey(sharedSecret: Priv, pub: Pub) -> Pub {
        let point = Secp256k1.pointAdd(pub.ecpoint, plus: sharedSecret.uint256)
        return Pub(point)
    }
    
    /// Generate ephemeral private key b' using shared secret s and private key b.
    /// b' is sutable for spending btcs received on B'
    ///
    /// - Parameters:
    ///   - sharedSecret: shared secret s
    ///   - priv: private key b
    /// - Returns: ephemeral private key b'
    static func ephemeralPrivKey(sharedSecret: Priv, priv: Priv) -> Priv {
        let point = Secp256k1.modAdd(priv.uint256, plus: sharedSecret.uint256)
        return Priv(point)
    }
    
    /// Generate ephemeral public key B' sutable for sending btcs in private manner.
    ///
    /// - Parameters:
    ///   - a: private key a (self 0th private key)
    ///   - b: public key B (other person's public key)
    /// - Returns: ephemeral public key B', nil if key generation failed (1/2^128 probablity)
    static func ephemeralPubKey(priv a: Priv, pub b: Pub) -> Pub? {
        let S = secretPoint(priv: a, pub: b)
        guard let s = scalarSharedSecret(S) else { return nil }
        return ephemeralPubKey(sharedSecret: s, pub: b)
    }
    
    /// Generate ephemeral private key b' sutable for spending btcs received on B'
    ///
    /// - Parameters:
    ///   - a: private key a (self private key)
    ///   - b: public key b (other person's 0th public key)
    /// - Returns: ephemeral private key b', nil if key generation failed (1/2^128 probability)
    static func ephemeralPrivKey(priv a: Priv, pub b: Pub) -> Priv? {
        let S = secretPoint(priv: a, pub: b)
        guard let s = scalarSharedSecret(S) else { return nil }
        return ephemeralPrivKey(sharedSecret: s, priv: a)
    }
    
    /// Generate payment code identifier (version 2 PC) for specified binary represented PC
    ///
    /// - Parameter data: PC binary representation
    /// - Returns: payment code identifier in form of Pub key
    static func paymentCodeIdentifier(with data: Data) -> Pub {
        var id = Data([0x02])       // 0x02 prefix
        let hash = data.sha256()
        id.append(hash)
        return Pub(data: id)
    }
}
