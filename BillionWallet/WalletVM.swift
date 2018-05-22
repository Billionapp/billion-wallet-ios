//
//  WalletVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol WalletVMDelegate: class {
    func currencyCartDidChanged(_ newCarts: [CurrencyDifferenceUserCart])
}

class WalletVM {
    weak var walletProvider: WalletProvider?
    weak var yieldProvider: YieldProvider?
    weak var defaults: Defaults?
    weak var delegate: WalletVMDelegate?
    weak var ratesProvider: RatesProvider?
    weak var feeProvider: FeeProvider?
    
    var balance: UInt64  {
        guard
            let walletProvider = self.walletProvider,
            let wallet = try? walletProvider.getWallet() else { return 0 }
        return wallet.balance
    }
    
    var stringBalance: String {
        return Satoshi.amount(UInt64(balance))
    }
    
    var localCurrency: String {
        return CurrencyFactory.defaultCurrency.code
    }
    
    var selectedInterval = TimeIntervals.today {
        didSet {
            calculateDiference()
        }
    }
    
    init(walletProvider: WalletProvider, yieldProvider: YieldProvider, defaults: Defaults, ratesProvider: RatesProvider, feeProvider: FeeProvider) {
        self.walletProvider = walletProvider
        self.yieldProvider = yieldProvider
        self.defaults = defaults
        self.ratesProvider = ratesProvider
        self.feeProvider = feeProvider
    }
    
    func didSelect(_ interval: TimeIntervals) {
        if selectedInterval != interval {
            selectedInterval = interval
        }
    }
    
    func calculateDiference() {
        guard let yield = yieldProvider else {return}
        guard let def = defaults else {return}
        let currenciesCarts = yield.getDifference(with: def.currencies, since: selectedInterval, from: (ratesProvider?.ratesHistory)!)
        delegate?.currencyCartDidChanged(currenciesCarts)
    }
    
    func balanceForIso(_ iso: String) -> Double {
        var balance: Double = 0
        guard let provider = ratesProvider else {return balance}
        for rate in provider.ratesCash {
            if (rate.currencyCode == iso) {
                balance = Double(self.balance)*rate.btc/pow(10, 8)
            }
        }
        
        return balance
    }
}
