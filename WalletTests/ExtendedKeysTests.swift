//
//  ExtendedPublicKeysTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
import CryptoSwift
@testable import BillionWallet

class ExtendedKeysTests: XCTestCase {
    
    var extendedKeys: [String] = []
    var keys: [String] = []
    var keysx: [String] = []
    
    override func setUp() {
        super.setUp()
        
        for _ in 0..<100 {
            var keyData = [UInt8]()
            keyData.append(0x02)
            for _ in 0..<64 {
                let r = UInt8(arc4random_uniform(UInt32(UINT8_MAX)))
                keyData.append(r)
            }
            extendedKeys.append(keyData.toHexString())
            
            var kData = [UInt8]()
            var xData = [UInt8]()
            kData.append(0x03)
            for _ in 0..<32 {
                let r = UInt8(arc4random_uniform(UInt32(UINT8_MAX)))
                kData.append(r)
                xData.append(r)
            }
            keys.append(kData.toHexString())
            keysx.append(xData.toHexString())
        }
    }
    
    func test() {
        for i in 0..<extendedKeys.count {
            let kData = Data([UInt8](hex: extendedKeys[i]))
            let pub = XPub(kData)
            let pubHex = pub.data.toHexString()
            
            XCTAssert(pubHex == extendedKeys[i],"\(pubHex) != \(extendedKeys[i])")
        }
        
        for i in 0..<keys.count {
            let kData = Data([UInt8](hex: keys[i]))
            let xData = Data([UInt8](hex: keysx[i]))
            let pub = Pub(data: kData)
            let x = BIP47.xFromPub(pub)
            
            XCTAssert(x.data.toHexString() == xData.toHexString(), "\(x.data.toHexString()) != \(xData.toHexString())")
        }
    }
}
