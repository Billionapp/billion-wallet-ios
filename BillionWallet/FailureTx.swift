//
//  FailureTransaction.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

/// Failed transaction data, that could be used to recreate that transaction
struct FailureTx: Codable {
    /// Creation timestampt
    let identifier: String
    /// Recipient address, not a PC
    let address: String
    /// Request amount satoshi
    let amount: UInt64
    /// Fee, may be outdated
    let fee: UInt64
    /// Comment of transaction
    let comment: String
    /// Contact uniq string id
    let contactID: String?
}

extension FailureTx: Equatable {
    static func ==(lhs: FailureTx, rhs: FailureTx) -> Bool {
        return lhs.address == rhs.address
            && lhs.amount == rhs.amount
            && lhs.fee == rhs.fee
            && lhs.comment == rhs.comment
            && lhs.contactID == rhs.contactID
    }
}

extension FailureTx {
    
    init (identifier: String, address: String, amount: UInt64, fee: UInt64, comment: String, contactID: String) {
        self.identifier = identifier
        self.address = address
        self.amount = amount
        self.fee = fee
        self.comment = comment
        self.contactID = contactID
    }
}
