//
//  Currency.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct Currency {

    let code: String
    let name: String
    let symbol: String
    var fractionDigits: Int
    
    init(code: String, name: String, symbol: String, fractionDigits: Int) {
        self.code = code
        self.name = name
        self.symbol = symbol
        self.fractionDigits = fractionDigits
    }
    
    var fullName: String {
        return "\(name) (\(code))"
    }
    
    var fullNameWithSymbol: String {
        return "\(symbol)\t\(fullName)"
    }
}

// MARK: - Equatable

extension Currency: Equatable {
    
    static func ==(lhs: Currency, rhs: Currency) -> Bool {
        return lhs.code == rhs.code
    }
    
}
