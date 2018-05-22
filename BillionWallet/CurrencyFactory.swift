//
//  CurrencyFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class CurrencyFactory {
    
    static var defaultCurrency: Currency {
        return unsafeCurrencyWithCode("USD")
    }
    
    static func allowedCurrenies() -> [Currency] {
        return ["USD", "HKD", "CNY", "EUR", "RUB", "JPY"].map { unsafeCurrencyWithCode($0) }
    }
    
    fileprivate static func unsafeCurrencyWithCode(_ currencyCode: String) -> Currency {
        return Currency(code: currencyCode,
                        name: name(for: currencyCode),
                        symbol: symbol(for: currencyCode),
                        fractionDigits: fractionDigits(for: currencyCode))
    }
    
    static func currencyWithCode(_ currencyCode: String) -> Currency? {
        // TODO: Fail creation if currency code is unknown
        // CurrencyFactory.allCodes() don't fit cause of BRWallet being weird
        return Currency(code: currencyCode,
                        name: name(for: currencyCode),
                        symbol: symbol(for: currencyCode),
                        fractionDigits: fractionDigits(for: currencyCode))
    }
    
    
    static func fractionDigits(for currencyCode: String) -> Int {
        if currencyCode == "JPY" {
            return 0
        } else {
            return 2
        }
    }
    
    static func name(for currencyCode: String) -> String {
        let locale = Locale.current as NSLocale
        if let name = locale.displayName(forKey: NSLocale.Key.currencyCode, value: currencyCode) {
            return name
        } else {
            return currencyCode
        }
    }
    
    static func symbol(for currencyCode: String) -> String {
        let locale = Locale.current as NSLocale
        if let symbol = locale.displayName(forKey: NSLocale.Key.currencySymbol, value: currencyCode) {
            return symbol
        } else {
            return currencyCode
        }
    }
}
