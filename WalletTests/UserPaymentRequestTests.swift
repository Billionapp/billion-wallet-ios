//
//  UserPaymentRequestTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 07/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class UserPaymentRequestTests: XCTestCase {
    
    /// Given
    let state = UserPaymentRequestState.waiting
    let acceptState = UserPaymentRequestState.accepted
    let address = "1DjjhRy2HKQgXVw2wCHTbnNq2C4Wr7YdX"
    let amount: Int64 = 888
    let fee: Int64 = 1111
    let comment: String = "Comment for UserPaymentRequest test"
    let contactID: String = "PM8TJRYrf7V55HsZvuk84n5sWHRc75Xk98QY1aVv5i6GuiTbENRjTER9367LSc8Bhq661YcaNdWh2FvXmVgMPi82G46EzWXZ2qLdqtnSngVZwPukgsKr"
    let storageUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory , in: .userDomainMask).last!
    
    /// Then
    var _uprs: [UserPaymentRequest] = []
    var _uprsAccepted: [UserPaymentRequest] = []
    
    override func setUp() {
        let factory = UserPaymentRequestFactory()
        _uprs = [
            factory.createUserPaymentRequest(identifier: nil,
                                             state: state,
                                             address: address,
                                             amount: amount,
                                             comment: comment,
                                             contactID: contactID)
        ]
        _uprsAccepted = [
            factory.createUserPaymentRequest(identifier: nil,
                                             state: acceptState,
                                             address: address,
                                             amount: amount,
                                             comment: comment,
                                             contactID: contactID)
        ]
    }
    
    func testCreateUserPaymentRequest() {
        let provider = DefaultUserPaymentRequestProviderFactory().createUserPaymentRequestProvider()
        
        // Client that creates UserPaymentRequest
        let expectation = self.expectation(forNotification: UserPaymentRequestEvent, object: nil, handler: nil)
        provider.createUserPaymentRequest(identifier: nil,
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
        
        let uprs = provider.allUserPaymentRequests
        XCTAssertEqual(uprs, _uprs)
        
        // Acception inner request
        guard let upr = uprs.first else {
            XCTFail()
            return
        }
        provider.changeToState(identifier: upr.identifier,
                               state:UserPaymentRequestState.accepted,
        completion: {
            XCTAssertEqual(uprs, self._uprsAccepted)
        }) { (error) in
            XCTFail(error.localizedDescription)
        }
        
        // The client delete request
        provider.deleteUserPaymentRequest(identifier: upr.identifier, completion: {
            XCTAssert(provider.allUserPaymentRequests.count == 0)
        }) { (error) in
            XCTFail(error.localizedDescription)
        }
    }
}

