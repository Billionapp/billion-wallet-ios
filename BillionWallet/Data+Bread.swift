//
//  Data+Bread.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

fileprivate extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
    
    var rawBytes: UnsafeRawPointer {
        return self.withUnsafeBytes { UnsafeRawPointer($0) }
    }
}

struct ECPointS {
    var ecpoint: ECPoint
    
    var sign: UInt8 {
        return ecpoint.p.0
    }
    
    var x: UInt256S {
        let d = self.data.subdata(in: Range<Int>(1..<33))
        return UInt256S(data: d)
    }
    
    init(data: Data) {
        self.ecpoint = data.to(type: ECPoint.self)
    }
    
    init(_ ecpoint: ECPoint) {
        self.ecpoint = ecpoint
    }
    
    var data: Data {
        return Data(from: self.ecpoint)
    }
}

struct TXOutpointS {
    var outpoint: TXOutpoint
    
    var txId: UInt256S {
        let d = Data(from: outpoint.txid)
        return UInt256S(data: d)
    }
    
    var index: UInt32 {
        return outpoint.index
    }
    
    init(data: Data) {
        self.outpoint = data.to(type: TXOutpoint.self)
    }
    
    init(_ outpoint: TXOutpoint) {
        self.outpoint = outpoint
    }
    
    var data: Data {
        return Data(from: self.outpoint)
    }
}

struct UInt256S {
    var uint256: UInt256
    
    var u8: [UInt8] {
        return [UInt8](data)
    }
    var u16: [UInt16] {
        let u: [UInt16] = [
            uint256.u16.0, uint256.u16.1, uint256.u16.2, uint256.u16.3,
            uint256.u16.4, uint256.u16.5, uint256.u16.6, uint256.u16.7,
            uint256.u16.8, uint256.u16.9, uint256.u16.10, uint256.u16.11,
            uint256.u16.12, uint256.u16.13, uint256.u16.14, uint256.u16.15
        ]
        return u
    }
    var u32: [UInt32] {
        let u: [UInt32] = [
            uint256.u32.0, uint256.u32.1, uint256.u32.2, uint256.u32.3,
            uint256.u32.4, uint256.u32.5, uint256.u32.6, uint256.u32.7
        ]
        return u
    }
    var u64: [UInt64] {
        let u: [UInt64] = [
            uint256.u64.0,
            uint256.u64.1,
            uint256.u64.2,
            uint256.u64.3
        ]
        return u
    }
    
    init(data: Data = Data(repeating: 0x00, count: 32)) {
        self.uint256 = data.to(type: UInt256.self)
    }
    
    init(_ uint256: UInt256) {
        self.uint256 = uint256
    }
    
    init(bytes: [UInt8]) {
        self.init(data: Data(bytes))
    }
    
    var data: Data {
        return Data(from: self.uint256)
    }
}

struct UInt160S {
    var uint160: UInt160
    
    var u8: [UInt8] {
        return [UInt8](data)
    }
    var u16: [UInt16] {
        let u: [UInt16] = [
            uint160.u16.0, uint160.u16.1, uint160.u16.2, uint160.u16.3,
            uint160.u16.4, uint160.u16.5, uint160.u16.6, uint160.u16.7,
            uint160.u16.8, uint160.u16.9
        ]
        return u
    }
    var u32: [UInt32] {
        let u: [UInt32] = [
            uint160.u32.0, uint160.u32.1, uint160.u32.2, uint160.u32.3,
            uint160.u32.4
        ]
        return u
    }
    
    init(data: Data) {
        self.uint160 = data.to(type: UInt160.self)
    }
    
    init(_ uint160: UInt160) {
        self.uint160 = uint160
    }
    
    init(bytes: [UInt8]) {
        self.init(data: Data(bytes))
    }
    
    var data: Data {
        return Data(from: self.uint160)
    }
}

extension Data {
    init(uint128: UInt128) {
        self.init(NSData(uInt128: uint128) as Data)
    }
    
    init(uint160: UInt160) {
        self.init(NSData(uInt160: uint160) as Data)
    }
    
    init(uint256: UInt256) {
        self.init(NSData(uInt256: uint256) as Data)
    }
    
    init(base58: String) {
        self.init(NSData(base58String: base58) as Data)
    }

    init(scriptPubKeyForAddress address: String) {
        let mutableData = NSMutableData()
        mutableData.appendScriptPubKey(forAddress: address)
        self.init(mutableData as Data)
    }
    
    var base58String: String {
        return (self as NSData).base58String()
    }
    
    func base58CheckString(versionByte: UInt8) -> String {
        var d = Data()
        d.append(versionByte)
        d.append(self)
        return NSString.base58check(with: d) as String
    }
    
    var hash160: UInt160 {
        return (self as NSData).hash160()
    }
    
    mutating func append(_ uInt16: UInt16) {
        self.append(Data(from: uInt16))
    }
    
    mutating func append(_ uInt32: UInt32) {
        self.append(Data(from: uInt32))
    }
    
    mutating func append(_ uInt64: UInt64) {
        self.append(Data(from: uInt64))
    }
    
    func toUInt16() -> UInt16 {
        return self.to(type: UInt16.self)
    }
    
    func toUInt32() -> UInt32 {
        return self.to(type: UInt32.self)
    }
    
    func toUInt64() -> UInt64 {
        return self.to(type: UInt64.self)
    }
}

