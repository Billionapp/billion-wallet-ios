//
//  PaymentMethod.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct PaymentMethod: Equatable {
    let symbol: String
    let name: String
    
    static func ==(lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
        return lhs.symbol == rhs.symbol && rhs.name == rhs.name
    }
}
