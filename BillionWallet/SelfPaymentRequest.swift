//
//  SelfPaymentRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

enum SelfPaymentRequestState: Int, Codable {
    case inProgress
    case rejected
}

// Self request funds
struct SelfPaymentRequest: Codable {
    /// Creation timestampt
    let identifier: String
    // State of request
    var state: SelfPaymentRequestState
    // Recepient address, not a PC
    var address: String
    // Request amount satoshi
    var amount: Int64
    // Comment of transaction
    var comment: String = ""
    // Contact uniq string id
    var contactID: String?
}

extension SelfPaymentRequest {
    
    init (identifier: String, state: SelfPaymentRequestState, address: String, amount: Int64, comment: String, contactID: String) {
        self.identifier = identifier
        self.state = state
        self.address = address
        self.amount = amount
        self.comment = comment
        self.contactID = contactID
    }
}

extension SelfPaymentRequest: Equatable {
    static func ==(lhs: SelfPaymentRequest, rhs: SelfPaymentRequest) -> Bool {
        return lhs.state == rhs.state
            && lhs.address == rhs.address
            && lhs.amount == rhs.amount
            && lhs.comment == rhs.comment
            && lhs.contactID == rhs.contactID
    }
}
