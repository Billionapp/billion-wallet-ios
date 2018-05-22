//
//  Satoshi.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

struct Satoshi {
    
    static var formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.currencySymbol = Strings.satoshiSymbol
        formatter.positiveFormat = "#,###,## ¤"
        formatter.currencyGroupingSeparator = " "
        return formatter
    }()
    
    static func amount(_ amount: UInt64) -> String {
        let number = NSNumber(value: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.currencySymbol = Strings.satoshiSymbol
        formatter.positiveFormat = "#,###,## ¤"
        formatter.currencyGroupingSeparator = " "
        return formatter.string(for: number)!
    }
}
