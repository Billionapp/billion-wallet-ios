//
//  CurrencyHelper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

func localeFromIso(iso: String) -> Locale {
    for localeId in Locale.availableIdentifiers {
        let locale: NSLocale = NSLocale.init(localeIdentifier: localeId)
        if locale.currencyCode == iso {
            return locale as Locale
        }
    }
    return Locale.init(identifier: "us_US")
}

func stringCurrency(from amount: Double, localeIso: String) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
    currencyFormatter.maximumFractionDigits = 2
    currencyFormatter.locale = Locale.current
    currencyFormatter.currencyCode = localeIso
    return currencyFormatter.string(from: Decimal(amount) as NSDecimalNumber)!
}

func stringCurrencyRounded(from amount: Double, localeIso: String) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.maximumFractionDigits = 0
    currencyFormatter.locale = Locale.current
    currencyFormatter.currencyCode = localeIso
    currencyFormatter.numberStyle = .currency
    currencyFormatter.isLenient = true
    currencyFormatter.generatesDecimalNumbers = true
    currencyFormatter.minimumFractionDigits = 0
    currencyFormatter.maximumFractionDigits = 0
    
    return currencyFormatter.string(from: Decimal(amount) as NSDecimalNumber)!
}

func stringCurrencyFromDecimal(from amount: Decimal, localeIso: String) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
    currencyFormatter.maximumFractionDigits = 0
    currencyFormatter.locale = Locale.current
    currencyFormatter.currencyCode = localeIso
    return currencyFormatter.string(from: NSDecimalNumber(decimal: amount))!
}

func decimal(with string: String) -> NSDecimalNumber {
    let formatter = NumberFormatter()
    formatter.generatesDecimalNumbers = true
    return formatter.number(from: string) as? NSDecimalNumber ?? 0
}

func stringCurrencyAsNumber(from amount: NSDecimalNumber) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = NumberFormatter.Style.decimal
    currencyFormatter.maximumFractionDigits = 2
    return currencyFormatter.string(from: amount)!
}
