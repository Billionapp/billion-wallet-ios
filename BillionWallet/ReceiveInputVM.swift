//
//  ReceiveInputVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol ReceiveInputVMDelegate: class {
    func didEnterAmount()
    func deleteLastSymbol()
    func clearTextField()
    func updateTextField(with satoshi: String)
    func didSentRequest()
    func didFailedSent(with error: Error)
    func showPasscodeView(amount: String, amountLocal: String, comment: String)
    func didCancelVerification()
}

class ReceiveInputVM {
    
    typealias LocalizedStrings = Strings.ReceiveRequest
    
    private var contact: PaymentCodeContactProtocol
    private let ratesProvider: RateProviderProtocol
    private let walletProvider: WalletProvider
    private let messageSendProvider: RequestSendProviderProtocol
    private let lockProvider: LockProvider
    private let contactsProvider: ContactsProvider
    
    private let fiatConverter: FiatConverter
    private let btcFormatter: NumberFormatter
    private let currency: Currency
    private var roundedSatoshi: String?
    private var tempLocalAmount: Double = 0
    private var comment: String = ""
    
    private(set) var amount: UInt64 {
        didSet {
            if amount == 0 {
                title &= LocalizedStrings.receiveTitle
            } else {
                let localAmountString = fiatConverter.fiatStringForBtcValue(amount)
                title &= String(format: LocalizedStrings.receiveTitleAmountFormat, localAmountString)
                if currencyInputState == .localCurrency {
                    amountLabel &= localAmountString
                } else {
                    amountLabel &= btcFormatter.string(for: amount) ?? ""
                }
            }
            delegate?.didEnterAmount()
        }
    }
    private var currencyInputState: CurrencyButtonState
    
    var delegate: ReceiveInputVMDelegate?
    
    let receiverImageRepr: Dynamic<UIImage?>
    let title: Dynamic<String>
    let subtitle: Dynamic<String>
    let inputAmountPrefix: Dynamic<String>
    let amountLabel: Dynamic<String>
    
    init(contact: PaymentCodeContactProtocol,
         ratesProvider: RateProviderProtocol,
         defaultsProvider: Defaults,
         walletProvider: WalletProvider,
         lockProvider: LockProvider,
         contactsProvider: ContactsProvider,
         messageSendProvider: RequestSendProviderProtocol) {
        
        self.contact = contact
        self.contactsProvider = contactsProvider
        self.walletProvider = walletProvider
        self.ratesProvider = ratesProvider
        self.lockProvider = lockProvider
        self.currency = defaultsProvider.currencies.first!
        self.btcFormatter = Satoshi.formatter
        self.messageSendProvider = messageSendProvider
        
        self.currencyInputState = .localCurrency
        self.inputAmountPrefix = Dynamic(currency.symbol)
        let rateSource = DefaultRateSource(rateProvider: ratesProvider)
        self.fiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
        self.amount = 0
        self.title = Dynamic(LocalizedStrings.receiveTitle)
        self.subtitle = Dynamic(contact.givenName)
        self.receiverImageRepr = Dynamic(contact.avatarImage)
        self.amountLabel = Dynamic("")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    private func isRedundantFractionDigits(amount: String) -> Bool {
        let separator = Locale.current.decimalSeparator ?? "."
        guard let commaIndex = amount.index(of: Array(separator).first!) else { return false }
        let decimalPartIndex = amount.index(after: commaIndex)
        let decimalPartString = amount[decimalPartIndex...]
        
        if decimalPartString.count > currency.fractionDigits { return true}
        return false
    }
    
    private func checkStringForComma(text: String) {
        var str = text
        let separator = Locale.current.decimalSeparator ?? "."
        if let commaRange = str.range(of: separator) {
            str.removeSubrange(commaRange.lowerBound..<str.endIndex)
            roundedSatoshi = str
            amount = UInt64(roundedSatoshi!) ?? 0
        }
    }
    
    private func roundSatoshi(from fiat: Decimal) {
        if tempLocalAmount < 1  {
            amount = 0
            delegate?.clearTextField()
        } else {
            if let dec = roundedSatoshi {
                delegate?.updateTextField(with: dec)
            }
            roundedSatoshi = nil
        }
    }
    
    func changeCurrencyState(_ currencyState: CurrencyButtonState) {
        currencyInputState = currencyState
        inputAmountPrefix &= (currencyState == .satoshi) ? Strings.satoshiSymbol : currency.symbol
    }
    
    private func amountStringToDecimal(_ amountString: String) -> Decimal {
        // Here we can opt logic regarding amount string formatting
        // i.e. parse amount string through formatter
        let formatter = NumberFormatter()
        let number = formatter.number(from: amountString)?.decimalValue
        return number ?? 0
    }
    
    func changeAmountString(_ amountString: String) {
            switch currencyInputState {
            case .satoshi:
                amount = UInt64(amountString) ?? 0
                if amountString == "0" {
                    delegate?.deleteLastSymbol()
                    return
                }
                
                checkStringForComma(text: amountString)
            case .localCurrency:
                if isRedundantFractionDigits(amount: amountString) {
                    delegate?.deleteLastSymbol()
                    return
                }
                
                let value = amountStringToDecimal(amountString)
                tempLocalAmount = Double(truncating: value as NSNumber)
                amount = fiatConverter.convertToBtc(fiatValue: value)
            }
    }
    
    func didSendPressed(comment: String) {
        self.comment = comment
        
        guard !isDeviceLocked() else {
            let amountTotalSat = Satoshi.formatter.string(from: NSNumber(value: amount))!
            let amountTotalLocal = fiatConverter.fiatStringForBtcValue(amount)
            let title = LocalizedStrings.receiverTitle+" "+contact.displayName+"\n"+LocalizedStrings.amountTitle+" "+amountTotalLocal
            delegate?.showPasscodeView(amount: amountTotalSat, amountLocal: amountTotalLocal, comment: title)
            return
        }
        sendMessage(with: comment)
    }
    
    func isDeviceLocked() -> Bool {
        return lockProvider.isLocked
    }

    func isSyncingNow() -> Bool {
        return false
    }
    
    private func sendMessage(with comment: String) {
        delegate?.didSentRequest()
        
        var amountToSend: Int64!
        switch currencyInputState {
        case .localCurrency:
            let value = Decimal(tempLocalAmount)
            amountToSend = Int64(fiatConverter.convertToBtc(fiatValue: value))
        case .satoshi:
            amountToSend = Int64(amount)
        }
        messageSendProvider.sendRequest(address: "", amount: amountToSend, comment: comment, contact: contact) { result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self.delegate?.didFailedSent(with: error)
            }
        }
    }
    
    func updatePriority() {
        contact.lastUsed = NSNumber(value: Double(Date().timeIntervalSince1970))
        contactsProvider.save(contact)
    }
}

extension ReceiveInputVM: BillionKeyboardDelegate {
    func commaPressed() {}
    
    func deleteAllPressed() {
        self.changeAmountString("")
    }
    
    func numberPressed(_ num: Int) { }
    func deletePressed() { }
    
    // Use this to handle change currency from BillionKeyboard
    func changeCurrencyPressed(currency: CurrencyButtonState) {
        self.changeCurrencyState(currency)
        if currency == .satoshi {
            let fiat = fiatConverter.convertToFiat(btcValue: amount)
            roundSatoshi(from: fiat)
        }
    }
}

extension ReceiveInputVM: PasscodeOutputDelegate {
    
    func didCompleteVerification() {
        sendMessage(with: comment)
    }
    
    func didCancelVerification () {
        delegate?.didCancelVerification()
    }
    
}
