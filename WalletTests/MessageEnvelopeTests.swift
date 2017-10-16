//
//  MessageEnvelopeTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class MessageEnvelopeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()  
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSeriazation() {
        let i = UInt32(0x01)
        let j = UInt32(0x01)
        let c = Crypto.Random.data(64)
        let d = Crypto.Random.data(64)
        let envelope = MessageEnvelope(i, j, c, d)
        let binary = envelope.binaryFormat
        let envelopeDecoded = MessageEnvelope(data: binary)
        
        XCTAssertNotNil(envelopeDecoded, "Envelope failed to initialize")
        
        guard let envelope2 = envelopeDecoded else { return }
        
        XCTAssert(i == envelope2.i, "\(i) != \(envelope2.i)")
        XCTAssert(j == envelope2.j, "\(j) != \(envelope2.j)")
        XCTAssert(c == envelope2.c, "\(c.toHexString()) != \(envelope2.c.toHexString())")
        XCTAssert(d == envelope2.d, "\(d.toHexString()) != \(envelope2.d.toHexString())")
        XCTAssert(envelope.i == envelope2.i, "\(envelope.i) != \(envelope2.i)")
        XCTAssert(envelope.j == envelope2.j, "\(envelope.j) != \(envelope2.j)")
        XCTAssert(envelope.c == envelope2.c, "\(envelope.c.toHexString()) != \(envelope2.c.toHexString())")
        XCTAssert(envelope.d == envelope2.d, "\(envelope.d.toHexString()) != \(envelope2.d.toHexString())")
    }
    
    func testSerializationSpeed() {
        let i = UInt32(0x01)
        let j = UInt32(0x01)
        let c = Crypto.Random.data(64)
        let d = Crypto.Random.data(64)
        
        self.measure {
            for _ in 0..<10000 {
                let envelope = MessageEnvelope(i, j, c, d)
                let binary = envelope.binaryFormat
                let _ = MessageEnvelope(data: binary)
            }
        }
    }
}
