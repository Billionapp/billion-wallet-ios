//
//  PaymentRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

enum UserPaymentRequestState: Int, Codable {
    case waiting
    case accepted
    case declined
    case failed
}

// Other side request funds
struct UserPaymentRequest: Codable {
    /// Creation timestampt
    let identifier: String
    // State of request
    var state: UserPaymentRequestState
    // Recepient address, not a PC
    var address: String
    // Request amount satoshi
    var amount: Int64
    // Comment of transaction
    var comment: String = ""
    // Contact uniq string id
    var contactID: String?
}

extension UserPaymentRequest {
    
    init (identifier: String, state: UserPaymentRequestState, address: String, amount: Int64, comment: String, contactID: String) {
        self.identifier = identifier
        self.state = state
        self.address = address
        self.amount = amount
        self.comment = comment
        self.contactID = contactID
    }
}

extension UserPaymentRequest: Equatable {
    static func ==(lhs: UserPaymentRequest, rhs: UserPaymentRequest) -> Bool {
        return lhs.state == rhs.state
            && lhs.address == rhs.address
            && lhs.amount == rhs.amount
            && lhs.comment == rhs.comment
            && lhs.contactID == rhs.contactID
    }
}
