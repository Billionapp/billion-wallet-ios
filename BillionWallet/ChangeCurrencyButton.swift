//
//  ChangeCurrencyButton.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum CurrencyButtonState {
    case satoshi
    case localCurrency
}

class ChangeCurrencyButton: UIButton {
    
    fileprivate var displayedCurrency: String?
    fileprivate var displayedState = CurrencyButtonState.localCurrency

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel?.font = UIFont.systemFont(ofSize: 28)
        setTitle(Strings.satoshiSymbol, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
    }
    
    func changeTitle(with currency: String) {
        displayedCurrency = currency
        switch displayedState {
        case .localCurrency:
            switchTitle(isLocal: true)
            displayedState = .satoshi
            return
        case .satoshi:
            switchTitle(isLocal: false)
            displayedState = .localCurrency
            return
        }
    }
}

//MARK: - Private Methods
extension ChangeCurrencyButton {
    
    fileprivate func switchTitle(isLocal: Bool) {
        if isLocal {
            setTitle(displayedCurrency, for: .normal)
            setBackgroundImage(nil, for: .normal)
        } else {
            setTitle(Strings.satoshiSymbol, for: .normal)
        }
    }
}
