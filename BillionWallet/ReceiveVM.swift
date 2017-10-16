//
//  ReceiveVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ReceiveVMDelegate: class {
    func amountDidChange(text: String)
    func addressDidChange(text: String)
}

class ReceiveVM: NSObject, UITextFieldDelegate {
    var address: String? {
        didSet {
            guard let addressUn = address else { return }
            self.stringForQr = addressUn
            delegate?.addressDidChange(text: addressUn)
        }
    }
    let localeIso: String
    var amount: NSDecimalNumber {
        didSet {
            delegate?.amountDidChange(text: stringCurrencyFromDecimal(from: amount, localeIso: localeIso))
        }
    }
    weak var delegate: ReceiveVMDelegate? {
        didSet {
            delegate?.amountDidChange(text: stringCurrencyFromDecimal(from: amount, localeIso: localeIso))
        }
    }
    var stringForQr: String?
    weak var walletProvider: WalletProvider!
    weak var ratesProvider: RatesProvider!
    
    // MARK: - Lifecycle
    init(walletProvider: WalletProvider, localeIso: String, ratesProvider: RatesProvider) {
        self.walletProvider = walletProvider
        self.ratesProvider = ratesProvider
        self.localeIso = localeIso
        self.amount = decimal(with: "0")
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.length == 0 { //adding character
            if !CharacterSet.decimalDigits.contains(string.unicodeScalars.first!) && !(string.hasPrefix(".")){
                return false
            } else {
                let newString = "\(textField.text ?? "")\(string)"
                prepareStringForNonEmptyAmount(amountString: newString)
                amount = decimal(with: newString)
                return true
            }
        } else { //erase last character
            if range.location == 0  { //all characters was erased
                stringForQr = address!
                amount = decimal(with: "0")
            } else {
                let text = textField.text ?? ""
                let newString = String(text.characters.dropLast())
                prepareStringForNonEmptyAmount(amountString: newString)
                amount = decimal(with: newString)
            }
            
            return true
        }
    }
    
    func prepareStringForNonEmptyAmount(amountString:String) {
        guard let address = address else { return }
        let currency = CurrencyFactory.currencyWithCode(walletProvider.manager.localCurrencyCode ?? "USD")
        let converter = FiatConverter(currency: currency!, ratesSource: ratesProvider)
        let value = Decimal(string: amountString) ?? Decimal(0)
        let satAmount = Double(converter.convertToBtc(fiatValue: value))
        let btcAmount = satAmount/Double(1e8)
        stringForQr = "bitcoin:\(address)?amount=\(btcAmount)"
    }
    
    func qrFromString() -> UIImage? {
        let qrView = createQRFromString(stringForQr!, size: CGSize(width: 280, height: 280), inverseColor: true)
        return qrView
    }
    
    func getSelfAddress() {
        guard let addr = walletProvider.manager.wallet?.receiveAddress else {return}
        self.address = addr
    }
}
