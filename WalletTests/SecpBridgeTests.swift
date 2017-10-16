//
//  SecpBridgeTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class SecpBridgeTests: XCTestCase {
    
    func test() {
        for _ in  0...100 {
            let a: UInt256S = Crypto.Random.uInt256S()
            var aa = a
            let b: UInt256S = Crypto.Random.uInt256S()
            let p = Secp256k1.modAdd(a.uint256, plus: b.uint256)
            _ = invokeUnsafeMethod(BRSecp256k1ModAdd, arg1: &(aa.uint256), arg2: b.uint256)
            
            XCTAssert(p.u64.0 == aa.u64[0] &&
                p.u64.1 == aa.u64[1] &&
                p.u64.2 == aa.u64[2] &&
                p.u64.3 == aa.u64[3])
        }
    }
}
