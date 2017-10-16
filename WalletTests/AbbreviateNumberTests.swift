//
//  AbbreviateNumberTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class AbbreviateTests: XCTestCase {
    
    // given
    let _n1: Double = 999
    let _n2: Double = 1100
    let _n3: Double = 144000
    let _n4: Double = 123456789
    let _n5: Double = 12345678901234
    let _n6: Double = 1234567000
    
    //then
    let n1Str = "999.0"
    let n2Str = "1.1k"
    let n3Str = "144.0k"
    let n4Str = "123.5m"
    let n5Str = "12.3q"
    let n6Str = "1.2bi"
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFormatter() {
        let n1 = Helper.abbreviateAmount(_n1)
        let n2 = Helper.abbreviateAmount(_n2)
        let n3 = Helper.abbreviateAmount(_n3)
        let n4 = Helper.abbreviateAmount(_n4)
        let n5 = Helper.abbreviateAmount(_n5)
        let n6 = Helper.abbreviateAmount(_n6)
        
        XCTAssert(n1 == n1Str)
        XCTAssert(n2 == n2Str)
        XCTAssert(n3 == n3Str)
        XCTAssert(n4 == n4Str)
        XCTAssert(n5 == n5Str)
        XCTAssert(n6 == n6Str)
    }
}
