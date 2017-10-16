//
//  TransactionProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TransactionProvider {
    var tx: BRTransaction?
    var fee: UInt64?
    var amount: UInt64?
    
    init(tx: BRTransaction?, fee: UInt64?, amount: UInt64?) {
        self.tx = tx
        self.fee = fee
        self.amount = amount
    }    
}
