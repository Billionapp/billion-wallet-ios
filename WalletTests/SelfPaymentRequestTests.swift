//
//  SelfPaymentRequestTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 08/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class SelfPaymentRequestTests: XCTestCase {
    
    /// Given
    let state = SelfPaymentRequestState.inProgress
    let rejectState = SelfPaymentRequestState.rejected
    let address = "1DjjhRy2HKQgXVw2wCHTbnNq2C4Wr7YdX"
    let amount: Int64 = 333
    let fee: Int64 = 255
    let comment: String = "Comment for SelfPaymentRequest test"
    let contactID: String = "PM8TJRYrf7V55HsZvuk84n5sWHRc75Xk98QY1aVv5i6GuiTbENRjTER9367LSc8Bhq661YcaNdWh2FvXmVgMPi82G46EzWXZ2qLdqtnSngVZwPukgsKr"
    let storageUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory , in: .userDomainMask).last!
    
    /// Then
    var _sprs: [SelfPaymentRequest] = []
    var _sprsRejected: [SelfPaymentRequest] = []
    
    override func setUp() {
        let factory = SelfPaymentRequestFactory()
        _sprs = [
            factory.createSelfPaymentRequest(identifier: nil,
                                             state: state,
                                             address: address,
                                             amount: amount,
                                             comment: comment,
                                             contactID: contactID)
        ]
        _sprsRejected = [
            factory.createSelfPaymentRequest(identifier: nil,
                                             state: rejectState,
                                             address: address,
                                             amount: amount,
                                             comment: comment,
                                             contactID: contactID)
        ]
    }
    
    func testCreateSelfPaymentRequest() {
        let provider = DefaultSelfPaymentRequestProviderFactory().createSelfPaymentRequestProvider()
        
        // Client that creates SelfPaymentRequest
        let expectation = self.expectation(forNotification: SelfPaymentRequestEvent, object: nil, handler: nil)
        provider.createSelfPaymentRequest(identifier: nil,
                                          state: state,
                                          address: address,
                                          amount: amount,
                                          comment: comment,
                                          contactID: contactID,
                                          completion: { }, failure: { (error) in
            XCTFail(error.localizedDescription)
        })
        
        // Client that receives notification, and uses result
        self.wait(for: [expectation], timeout: 10)
        
        let sprs = provider.allSelfPaymentRequests
        XCTAssertEqual(sprs, _sprs)
        
        // Rejected from another side
        guard let spr = sprs.first else {
            XCTFail()
            return
        }
        provider.changeStateToRejected(identifier: spr.identifier, completion: {
            XCTAssertEqual(sprs, self._sprsRejected)
        }) { (error) in
            XCTFail(error.localizedDescription)
        }
        
        // The client delete request
        provider.deleteSelfPaymentRequest(identifier: spr.identifier, completion: {
            XCTAssert(provider.allSelfPaymentRequests.count == 0)
        }) { (error) in
            XCTFail(error.localizedDescription)
        }
    }
}

