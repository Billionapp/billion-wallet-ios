//
//  UserPaymentRequestFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class UserPaymentRequestFactory {
    func createUserPaymentRequest(identifier: String?,
                                  state: UserPaymentRequestState,
                                  address: String,
                                  amount: Int64,
                                  comment: String,
                                  contactID: String) -> UserPaymentRequest {
        
        return UserPaymentRequest(identifier: identifier ?? "\(Date().timeIntervalSince1970)",
                                  state: state,
                                  address: address,
                                  amount: amount,
                                  comment: comment,
                                  contactID: contactID)
    }
}
