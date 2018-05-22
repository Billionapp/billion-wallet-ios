//
//  ExchangeModel.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct ExchangeModel {
    var exchange: Exchange
    var rates: Rates?
    var method: PaymentMethod?
    var state: ExchangeState
}

struct ExchangeRate {
    let from: String
    let to: String
    let input: String
    let output: String
    
    init(from: String, to: String, input: String, output: String) {
        self.from = from
        self.to = to
        self.input = input
        self.output = output
    }
    
    init(json: JSON) {
        self.from = json["from"].stringValue
        self.to = json["to"].stringValue
        self.input = json["in"].stringValue
        self.output = json["out"].stringValue
    }
}

struct Rates {
    var buy: [ExchangeRateInfo]
    var sell: [ExchangeRateInfo]
    
    func buyRateForMethod(_ method: PaymentMethod) -> ExchangeRateInfo? {
        return buy.first(where: { $0.method == method.symbol })
    }
    
    func sellRateForMethod(_ method: PaymentMethod) -> ExchangeRateInfo? {
        return sell.first(where: { $0.method == method.symbol })
    }
    
    func bestBuyForCurrency(iso: String) -> ExchangeRateInfo? {
        return buy.max(by: { $0.rate.btc > $1.rate.btc })
    }
    
    func bestSellForCurrency(iso: String) -> ExchangeRateInfo? {
        return sell.max(by: { $0.rate.btc > $1.rate.btc })
    }
    
    func buyContainsMethod(_ method: PaymentMethod) -> Bool {
        return buy.contains(where: { $0.method == method.symbol })
    }
    
    func sellContainsMethod(_ method: PaymentMethod) -> Bool {
        return sell.contains(where: { $0.method == method.symbol })
    }

}

struct ExchangeRateInfo {
    let rate: Rate
    let method: String
}
