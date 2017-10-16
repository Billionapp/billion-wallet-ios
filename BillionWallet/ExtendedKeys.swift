//
//  ExtendedKeys.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// Extended private key
///
/// WARNING! No error handling
struct XPriv {
    /// x value - private key
    var x: UInt256S
    /// Chain code
    var c: UInt256S
    
    /// Corresponding extended public key
    var pub: XPub {
        return XPub(self)
    }
    /// xPriv data representation (x, c)
    var data: Data {
        var d = Data()
        d.append(x.data)
        d.append(c.data)
        return d
    }
    
    /// Initialize xPriv with data
    ///
    /// - Parameter data: data containing xPriv (64 bytes long)
    init(_ data: Data) {
        let xData = data.subdata(in: Range<Data.Index>(0..<32))
        let cData = data.subdata(in: Range<Data.Index>(32..<64))
        x = UInt256S(data: xData)
        c = UInt256S(data: cData)
    }
    
    /// Initialize xPriv with bytes array
    ///
    /// - Parameter bytes: bytes array representing xPriv (64 bytes long)
    init(_ bytes: [UInt8]) {
        self.init(Data(bytes))
    }
}

/// Extended public key 
///
/// WARNING! No error handling
struct XPub {
    /// X value - public key
    var X: ECPointS
    /// Chain code
    var c: UInt256S
    
    /// xPub data representation (X, c)
    var data: Data {
        var d = Data()
        d.append(X.data)
        d.append(c.data)
        return d
    }
    
    /// Initialize xPub with data
    ///
    /// - Parameter data: data containing xPub (65 bytes long)
    init(_ data: Data) {
        let xData = data.subdata(in: Range<Data.Index>(0..<33))
        let cData = data.subdata(in: Range<Data.Index>(33..<65))
        X = ECPointS(data: xData)
        c = UInt256S(data: cData)
    }
    
    /// Initialize xPub with it's xPriv
    ///
    /// - Parameter priv: xPriv
    init(_ priv: XPriv) {
        let point = Secp256k1.pointGen(priv.x.uint256)
        X = ECPointS(point)
        c = priv.c
    }
    
    /// Initialize xPub with bytes array
    ///
    /// - Parameter bytes: bytes array representing xPub (65 bytes long)
    init(_ bytes: [UInt8]) {
        self.init(Data(bytes))
    }
}
