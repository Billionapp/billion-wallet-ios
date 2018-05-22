//
//  FiatConverter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// An object, that can provide currency rates
protocol RatesSource: class {
    /// Get currently valid currency rate
    ///
    /// - Parameter currency: Currency, for which rate is looked up
    /// - Returns: Currently valid rate or nil if not found
    func rateForCurrency(_ currency: Currency) -> Rate?
}

class FiatConverter {
    
    var ratesSource: RatesSource!
    
    var fiatCurrency: Currency
    let formatter: NumberFormatter
    
    init(currency: Currency, ratesSource: RatesSource, locale: Locale = .current) {
        self.formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .currency
        formatter.currencyCode = currency.code
        formatter.isLenient = true
        formatter.generatesDecimalNumbers = true
        formatter.negativeFormat = String(format: "- %@", formatter.positiveFormat)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = currency.fractionDigits
        
        self.ratesSource = ratesSource
        self.fiatCurrency = currency
    }
    
    func changeCurrency(newCurrency: Currency) {
        fiatCurrency = newCurrency
        formatter.currencyCode = newCurrency.code
    }
    
    func fiatStringForFiatValue(_ fiatValue: Int64) -> String {
        let decimal = Decimal(fiatValue)
        return formatter.string(from: decimal as NSDecimalNumber) ?? ""
    }
    
    func btcStringForFiatValue(_ fiatValue: Int64) -> String {
        let decimal = Decimal(fiatValue)
        let amount = convertToBtc(fiatValue: decimal)
        return Satoshi.amount(UInt64(amount))
    }
    
    func fiatStringForBtcValue(_ btcValue: UInt64) -> String {
        let fiatValue = convertToFiat(btcValue: btcValue)
        return formatter.string(from: fiatValue as NSDecimalNumber) ?? ""
    }
    
    func btcValueFromFiatString(_ fiatString: String) -> UInt64 {
        let fiatValue: NSDecimalNumber = (formatter.number(from: fiatString) as? NSDecimalNumber) ?? NSDecimalNumber(value: 0)
        let btcValue = convertToBtc(fiatValue: fiatValue as Decimal)
        return btcValue
    }
    
    func convertToFiat(btcValue: UInt64) -> Decimal {
        guard let rate = ratesSource.rateForCurrency(fiatCurrency) else {
            return 0
        }
        
        let fiatValue = Decimal(btcValue) * Decimal(rate.btc) / Decimal(1e8)
        
        return fiatValue
    }
    
    func convertToBtc(fiatValue: Decimal) -> UInt64 {
        guard let rate = ratesSource.rateForCurrency(fiatCurrency) else {
            return 0
        }
        
        let btcValue = ((fiatValue * Decimal(1e8) / Decimal(rate.btc)) as NSDecimalNumber).doubleValue
        
        return UInt64(round(btcValue))
    }
}

// MARK: CurrencyFactory
extension FiatConverter {
    convenience init?(currencyCode: String, ratesSource: RatesSource) {
        guard let currency = CurrencyFactory.currencyWithCode(currencyCode) else {
            return nil
        }
        
        self.init(currency: currency, ratesSource: ratesSource)
    }
}
