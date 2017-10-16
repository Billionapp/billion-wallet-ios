//
//  YieldProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum TimeIntervals: Int {
    case year = 0
    case halfYear
    case threeMonthes
    case month
    case week
    case yesterday
    case today
    
    var timestamp: Int {
        switch self {
        case .today:
            return nowTs
        case .yesterday:
            return nowTs - 86400
        case .week:
            return nowTs - 604800
        case .month:
            return nowTs - 2629743
        case .threeMonthes:
            return nowTs - (2629743*3)
        case .halfYear:
            return nowTs - (2629743 * 6)
        case .year:
            return nowTs -  31556926
        }
    }
    
    static var count = 7
    
    private var nowTs: Int {
        return Int(Date().timeIntervalSince1970)
    }
}

class YieldProvider {
    
    weak var defaults: Defaults?
    
    init(defaults: Defaults) {
        self.defaults = defaults
    }
    
    func getDifference(with currencies: [Currency], since ts: TimeIntervals, from history: [RateHistory]) -> [CurrencyDifferenceUserCart] {
        var outputArray = [CurrencyDifferenceUserCart]()
        let filteredArray = txSince(interval: ts, rateHistory: history)

        for currency in currencies {
            let iso = currency.code
            let diff = rateBalance(filteredTx: filteredArray, currency: currency) - constRateBalance(filteredTx: filteredArray, currency: currency)
            let diffCard = CurrencyDifferenceUserCart(ISO: iso, difference: diff)
            outputArray.append(diffCard)
        }
        
        return outputArray
    }
}

extension YieldProvider {
    private func txSince(interval: TimeIntervals, rateHistory: [RateHistory]) -> [RateHistory] {
        var outputArray = [RateHistory]()
        for rate in rateHistory {
            if (interval.timestamp <= rate.txts) {
                outputArray.append(rate)
            }
        }
        
        return outputArray
    }
    
    private func constRateBalance(filteredTx: [RateHistory], currency: Currency) -> Double {
        var firstRate: Double = 0
        var balance: Double = 0
        guard filteredTx.count != 0 else {return 0}
        filteredTx[0].rates.forEach { (rate) in
            if rate.currencyCode == currency.code {
                firstRate = rate.btc
            }
        }
        
        for tx in filteredTx {
            balance += Double(tx.amount)*firstRate/1e8
        }

        return balance
    }
    
    private func rateBalance(filteredTx: [RateHistory], currency: Currency) -> Double {
        var balance: Double = 0
        guard filteredTx.count != 0 else {return 0}
        for tx in filteredTx {
            var neededRate: Double = 0
            tx.rates.forEach({ (rate) in
                if rate.currencyCode == currency.code {
                    neededRate = rate.btc
                }
            })
            balance += neededRate * Double (tx.amount)/1e8
        }

        return balance
    }
}

struct CurrencyDifferenceUserCart {
    let ISO: String
    let difference: Double
}
