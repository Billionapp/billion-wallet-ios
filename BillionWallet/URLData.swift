//
//  URLData.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct BitcoinUrlData {
    let address: String
    let amount: Int64?
    
    init(address: String, amount: Int64? = nil) {
        self.address = address
        self.amount = amount
    }
}

struct BillionUrlData {
    let pc: String
    let name: String
}

