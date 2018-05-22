//
//  ReceiveVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ReceiveVMDelegate: class {
    func amountDidChange(amount: UInt64)
    func addressDidChange(text: String)
    func currencyDidChange()
    func clearTextField()
    func updateTextField(with satoshi: String)
}

class ReceiveVM: NSObject, UITextFieldDelegate {
    weak var walletProvider: WalletProvider!
    private let ratesSource: RatesSource
    weak var delegate: ReceiveVMDelegate?
    var stringForQr: String?
    let uriComposer: URIComposer
    var customKeyboardCurrencyState: CurrencyButtonState = .localCurrency
    
    private var currentAmount: UInt64
    private var roundedSatoshi: String?
    private var defaults: Defaults
    
    var address: String? {
        didSet {
            guard let addressUn = address else { return }
            self.stringForQr = "bitcoin:\(addressUn)"
            delegate?.addressDidChange(text: addressUn)
        }
    }
    
    var amount: UInt64 {
        didSet {
            stringForQr = uriComposer.getPaymentRequestURI(with: amount, address: address!, withSlashes: false)
            delegate?.amountDidChange(amount:amount)
        }
    }
    
    var fractionDigits: Int {
        let currency = defaults.currencies.first!
        return currency.fractionDigits
    }
    
    // MARK: - Lifecycle
    init(walletProvider: WalletProvider,
         ratesProvider: RateProviderProtocol,
         uriComposer: URIComposer,
         defaults: Defaults) {
        
        self.walletProvider = walletProvider
        self.ratesSource = DefaultRateSource(rateProvider: ratesProvider)
        self.amount = 0
        currentAmount = amount
        self.uriComposer = uriComposer
        self.defaults = defaults
    }
    
    var currencySymbol: String {
        let currency = defaults.currencies.first!
        return currency.symbol
    }
    
    var localAmountString: String {
        let currency = defaults.currencies.first!
        let converter = FiatConverter(currency: currency, ratesSource: ratesSource)
        return converter.fiatStringForBtcValue(amount)
    }
    
    func amountTextDidChange(text: String) {
        currentAmount = UInt64(text) ?? UInt64(0)
        switch customKeyboardCurrencyState {
        case .localCurrency:
            let value = Decimal(string: text) ?? Decimal(0)
            let currency = defaults.currencies.first!
            let converter = FiatConverter(currency: currency, ratesSource: ratesSource)
            amount = converter.convertToBtc(fiatValue: value)
            checkStringForComma(text: text)
        case .satoshi:
            amount = UInt64(text) ?? UInt64(0)
        }
    }
    
    private func checkStringForComma(text: String) {
        var str = text
        let separator = Locale.current.decimalSeparator ?? "."
        if let commaRange = str.range(of: separator) {
            str.removeSubrange(commaRange.lowerBound..<str.endIndex)
            roundedSatoshi = str
            currentAmount = UInt64(str) ?? UInt64(0)
        }
    }
    
    private func roundSatoshi(from fiat: Decimal) {
        if fiat < 1  {
            amount = 0
            delegate?.clearTextField()
        } else {
            if let dec = roundedSatoshi {
                delegate?.updateTextField(with: dec)
                roundedSatoshi = nil
            }
            amount = currentAmount
        }
    }
    
    func qrFromString() -> UIImage? {
        let qrView = createQRFromString(stringForQr!, size: CGSize(width: 400, height: 400), inverseColor: true)
        return qrView
    }
    
    func getSelfAddress() {
        guard let wallet = try? walletProvider.getWallet() else { return }
        
        let addr = wallet.receiveAddress
        self.address = addr
    }
    
    func sharingBip21String() -> String? {
        return uriComposer.getPaymentRequestURI(with: amount, address: address!, withSlashes: true)
    }
}

extension ReceiveVM: BillionKeyboardDelegate {
    func commaPressed() {}
    
    func numberPressed(_ num: Int) {}
    
    func deletePressed() {}
    
    func deleteAllPressed() {
        amount = 0
        currentAmount = 0
    }
    
    func changeCurrencyPressed(currency: CurrencyButtonState) {
        let fiatCurrency = defaults.currencies.first!
        let converter = FiatConverter(currency: fiatCurrency, ratesSource: ratesSource)
        customKeyboardCurrencyState = currency
        
        switch customKeyboardCurrencyState {
        case .localCurrency:
            amount = converter.convertToBtc(fiatValue: Decimal(currentAmount))
            delegate?.currencyDidChange()
        case .satoshi:
            let fiat = converter.convertToFiat(btcValue: amount)
            roundSatoshi(from: fiat)
            delegate?.currencyDidChange()
        }
    }
}
