//
//  UITextField+BillionKeyboardDelegate.swift
//  Billion Keyboard
//
//  Created by Evolution Group Ltd on 16.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

private var billionKeyboardDelegate: BillionKeyboardDelegate? = nil

extension UITextField: BillionKeyboardDelegate {
    func commaPressed() {
        let separator = Locale.current.decimalSeparator ?? "."
        if (text?.isEmpty)! { return }
        if text?.last == Array(separator).first { return }
        if (text?.contains(separator))! { return }
        self.insertText(separator)
        billionKeyboardDelegate?.commaPressed()
    }
    
    func changeCurrencyPressed(currency: CurrencyButtonState) {
        billionKeyboardDelegate?.changeCurrencyPressed(currency: currency)
    }
    
    func numberPressed(_ num: Int) {
        if (text?.first == "0") && (text?.last == "0") {
            return
        }
        
        self.insertText("\(num)")
        billionKeyboardDelegate?.numberPressed(num)
    }
    
    func deletePressed() {
        self.deleteBackward()
        billionKeyboardDelegate?.deletePressed()
    }
    
    func setbillionKeyboard(delegate: BillionKeyboardDelegate?, currency: Defaults? = nil) {
    
        let billionKeyboard = BillionKeyboardView(frame: CGRect(x: 0, y: 0, width: 0, height: keyboardHeight()))
        
        self.inputView = billionKeyboard
        billionKeyboardDelegate = delegate
        billionKeyboard.delegate = self
        guard let localCurrency = currency else { return }
        if let defaultsCurrency = localCurrency.currencies.first {
            billionKeyboard.choosenCurrency = defaultsCurrency
        } else {
            billionKeyboard.choosenCurrency = CurrencyFactory.defaultCurrency
        }
        
    }
    
    func deleteAllPressed() {
        text = ""
        billionKeyboardDelegate?.deleteAllPressed()
    }
    
    func unsetBillionKeyboard() {
        if let billionKeyboard = self.inputView as? BillionKeyboardView {
            billionKeyboard.delegate = nil
        }
        self.inputView = nil
        billionKeyboardDelegate = nil
    }
}

func keyboardHeight() -> CGFloat {
    switch UIScreen.main.bounds.height {
    case 812:
        return 291
    case 736:
        return 226
    case 667:
        return 216
    case 568:
        return 216
    default:
        return 219
    }
}
