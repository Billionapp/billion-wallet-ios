//
//  FailureTransactionFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class FailureTxFactory {
    func createFailureTx(address: String,
                         amount: UInt64,
                         fee: UInt64,
                         comment: String,
                         contactID: String) -> FailureTx {
        
        return FailureTx(identifier: "\(Date().timeIntervalSince1970)",
                         address: address,
                         amount: amount,
                         fee: fee,
                         comment: comment,
                         contactID: contactID)
    }
}
