//
//  ImportPrivKeyTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class ImportPrivKeyTests: XCTestCase {
    let manager = BRWalletManager.sharedInstance()
    
    //given constants
    let _testnetPrivKey = "93FKQ4vyH3sqjqfijn2zpEjP6GR6aSm1gavc8arNWyG4r2kK2aX"
    let _mainnetPrivKey = "L33THQjJVXGcg9q8f2jZ4d5jgiSvpXT6KbVz4tHCSKg2NPwJMszK"
    let _testnetAddr = "mzXqtKQM4uwsf4k4iTqLBuYXwK9m73w29Z"
    let _mainnetAddr = "13DUh4HyuZbLAiQZgN73ZV5LzmD3gR8v2A"
    let _emptyTestnetPrivKey = "92ajHVVBbUYkpqEHrpu7vu8e5QFvh44UsPUGd3Hi4QZwXhPXC2V"
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBlockCypher() {
        Api_Wrapper.getUTXOsFor(address: "mk8AJuoysQPf9HLeAGM4fuBcMuuVXKv4P2", successBlock: { (response) in
            XCTAssert(true, "Coming")
            print(response)
        }) { (error) in
            XCTFail()
        }
    }
    
    func testPrivateKey() {
        let validTestNetPrivKey = _testnetPrivKey.isValidBitcoinPrivateKey
        XCTAssert(!validTestNetPrivKey)
        
        let validMainnetPrivKey = _mainnetPrivKey.isValidBitcoinPrivateKey
        XCTAssert(validMainnetPrivKey)
    }
    /*
    func testEmptyPrivateKey() {
        let sem = DispatchSemaphore(value: 0)
        
        manager?.generateTransaction(withPrivate: _emptyTestnetPrivKey, success: { (tx, fee) in
            XCTFail()
            sem.signal()
        }, failure: { (error) in
            XCTAssertTrue(error.domain == "BreadWallet")
            sem.signal()
        })
        
        sem.wait(timeout: .distantFuture)
    }*/
}
