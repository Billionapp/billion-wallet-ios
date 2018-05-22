//
//  SelfPaymentRequestFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SelfPaymentRequestFactory {
    func createSelfPaymentRequest(identifier: String?,
                                  state: SelfPaymentRequestState,
                                  address: String,
                                  amount: Int64,
                                  comment: String,
                                  contactID: String) -> SelfPaymentRequest {
        
        return SelfPaymentRequest(identifier: identifier ?? "\(Date().timeIntervalSince1970)",
                                  state: state,
                                  address: address,
                                  amount: amount,
                                  comment: comment,
                                  contactID: contactID)
    }
}
