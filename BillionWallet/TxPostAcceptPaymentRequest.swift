//
//  TxPostAcceptPaymentRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxPostAcceptPaymentRequest: TxPostPublish {
    
    let paymentRequestProvider: UserPaymentRequestProtocol
    let paymentRequest: UserPaymentRequest
    
    init(paymentRequest: UserPaymentRequest, paymentRequestProvider: UserPaymentRequestProtocol) {
        self.paymentRequest = paymentRequest
        self.paymentRequestProvider = paymentRequestProvider
    }
    
    func performPostPublishTasks(_ transactions: [Transaction]) {
        paymentRequestProvider.changeToState(identifier: paymentRequest.identifier, state: .accepted, completion: {
            Logger.info("Payment request confirmed")
        }, failure: { error in
            Logger.error(error.localizedDescription)
        })
    }
}
