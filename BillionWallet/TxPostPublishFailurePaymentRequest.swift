//
//  TxPostPublishFailurePaymentRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TxPostPublishFailurePaymentRequest: TxPostPublish {
    
    let userPaymentRequest: UserPaymentRequest
    let userPaymentRequestProvider: UserPaymentRequestProtocol
    
    init(userPaymentRequest: UserPaymentRequest, userPaymentRequestProvider: UserPaymentRequestProtocol) {
        self.userPaymentRequest = userPaymentRequest
        self.userPaymentRequestProvider = userPaymentRequestProvider
    }
    
    func performPostPublishTasks(_ transactions: [Transaction]) {
        userPaymentRequestProvider.changeToState(identifier: userPaymentRequest.identifier, state: .failed, completion: {
            Logger.info("User payment request state changed to failed")
        }) { error in
            Logger.error(error.localizedDescription)
        }
    }

}
