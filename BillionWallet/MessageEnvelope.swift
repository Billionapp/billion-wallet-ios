//
//  MessageEnvelope.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct MessageEnvelope {
    var version: UInt8 = 1
    var i: UInt32   // Sender index
    var j: UInt32   // Recipient index
    var c: Data     // Ciphertext
    var d: Data     // ciphertext auth Digest
    
    init(_ i: UInt32, _ j: UInt32, _ c: Data, _ d: Data) {
        self.i = i
        self.j = j
        self.c = c
        self.d = d
    }
    
    init?(data: Data) {
        version = data[0]
        guard version == 0x01 else { return nil }
        
        i = data.subdata(in: Range<Int>(4..<8)).toUInt32()
        j = data.subdata(in: Range<Int>(8..<12)).toUInt32()
        let cLen = Int(data.subdata(in: Range<Int>(12..<16)).toUInt32())
        let cRange = Range<Int>(uncheckedBounds: (lower: 16, upper: cLen+16))
        let dRange = Range<Int>(uncheckedBounds: (lower: cRange.upperBound, upper: data.count))
        c = data.subdata(in: cRange)
        d = data.subdata(in: dRange)
    }
    
    var binaryFormat: Data {
        var data = Data()
        // Header
        data.append(version)            // 0
        data.append(UInt16(0x0000))     // 1-2
        data.append(UInt8(0x00))        // 3
        data.append(i)                  // 4-7
        data.append(j)                  // 8-11
        data.append(UInt32(c.count))    // 12-15
        
        // Payload
        data.append(c)                  // 16-(c.count+15)
        data.append(d)                  // (c.count+16)-(c.count+d.count+15)
        return data
    }
}
