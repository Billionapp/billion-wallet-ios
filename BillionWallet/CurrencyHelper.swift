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

func stringCurrency(from amount: UInt64, localeIso: String) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
    currencyFormatter.maximumFractionDigits = 0
    currencyFormatter.locale = Locale.current // localeFromIso(iso: localeIso)
    currencyFormatter.currencyCode = localeIso
    return currencyFormatter.string(from: Decimal(amount) as NSDecimalNumber)!
}

func stringCurrencyFromDecimal(from amount: NSDecimalNumber, localeIso: String) -> String {
    let currencyFormatter = NumberFormatter()
    currencyFormatter.numberStyle = NumberFormatter.Style.currencyAccounting
    currencyFormatter.maximumFractionDigits = 0
    currencyFormatter.locale = Locale.current //localeFromIso(iso: localeIso)
    currencyFormatter.currencyCode = localeIso
    return currencyFormatter.string(from: amount)!
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
