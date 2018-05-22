//
//  FailureTransactionTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 08/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class FailureTransactionTests: XCTestCase {
    
    /// Given
    let address = "1DjjhRy2HKQgXVw2wCHTbnNq2C4Wr7YdX"
    let amount: UInt64 = 555
    let fee: UInt64 = 110
    let comment: String = "Comment for FailureTransaction test"
    let contactID: String = "PM8TJRYrf7V55HsZvuk84n5sWHRc75Xk98QY1aVv5i6GuiTbENRjTER9367LSc8Bhq661YcaNdWh2FvXmVgMPi82G46EzWXZ2qLdqtnSngVZwPukgsKr"
    let storageUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory , in: .userDomainMask).last!
    
    /// Then
    var _failureTxs: [FailureTx] = []
    
    override func setUp() {
        let factory =  FailureTxFactory()
        _failureTxs = [
            factory.createFailureTx(address: address,
                                    amount: amount,
                                    fee: fee,
                                    comment: comment,
                                    contactID: contactID)
        ]
    }
    
    func testCreateFailureTx() {
        let provider = DefaultFailureTxProviderFactory().createFailureTxProvider()
        
        // Client that creates Failure Tx
        let expectation = self.expectation(forNotification: FailureTransactionsEvent, object: nil, handler: nil)
        provider.createFailureTx(address: address, amount: amount, fee: fee, comment: comment, contactID: contactID, completion: { }, failure: { (error) in
            XCTFail(error.localizedDescription)
        })
        
        // Client that receives notification, and uses result
        self.wait(for: [expectation], timeout: 10)
        
        let failureTxs = provider.allFailureTxs
        XCTAssertEqual(failureTxs, _failureTxs)
        
        // The client repeats sending
        guard let ftx = failureTxs.first else {
            XCTFail()
            return
        }
        provider.deleteFailureTx(identifier: ftx.identifier, completion: {
            XCTAssert(provider.allFailureTxs.count == 0)
        }) { (error) in
            XCTFail(error.localizedDescription)
        }
    }
}
