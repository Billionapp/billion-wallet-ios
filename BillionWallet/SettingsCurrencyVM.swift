//
//  SettingsCurrencyVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol SettingsCurrencyVMDelegate: class {
}

class SettingsCurrencyVM {
    
    let defaultsProvider: Defaults
    weak var walletProvider: WalletProvider?
    
    weak var delegate: SettingsCurrencyVMDelegate?
    var selectedCurrencies: [Currency]
    
    init(defaultsProvider: Defaults, walletProvider:WalletProvider) {
        self.walletProvider = walletProvider
        self.defaultsProvider = defaultsProvider
        self.selectedCurrencies = defaultsProvider.currencies
    }
    
    func save() {
        defaultsProvider.currencies = selectedCurrencies
        NotificationCenter.default.post(name: .walletSwitchCurrencyNotificationName,
                                        object: nil)
    }
    
}
