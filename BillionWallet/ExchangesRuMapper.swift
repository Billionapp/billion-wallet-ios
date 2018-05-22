//
//  ExchangesRuMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ExchangesRuMapper: ExchangesMapperProtocol {
    
    let country: String
    let currency: String
    
    init(country: String, currency: String) {
        self.country = country
        self.currency = currency
    }
    
    func map(_ json: JSON) -> [String: Rates] {
        let data = json.arrayValue
        
        var dict = [String: Rates]()
        
        for object in data {
            let objectData = object["data"]["item"].arrayValue
            let exchangeRates = objectData.map { ExchangeRate(json: $0) }
            
            var buy = [ExchangeRateInfo]()
            var sell = [ExchangeRateInfo]()
            
            for exchangeRate in exchangeRates {
                if exchangeRate.from == "BTC" {
                    guard
                        let index = Double(exchangeRate.output),
                        exchangeRate.to.range(of: self.currency) != nil else {
                            continue
                    }
                    let timestamp = Int64(Date().timeIntervalSince1970)
                    let rate = Rate(currencyCode: self.currency, btc: index, blockTimestamp: timestamp)
                    let method = exchangeRate.to
                    let info = ExchangeRateInfo(rate: rate, method: method)
                    sell.append(info)
                } else if exchangeRate.to == "BTC" {
                    guard
                        let index = Double(exchangeRate.input),
                        exchangeRate.from.range(of: self.currency) != nil else {
                            continue
                    }
                    let timestamp = Int64(Date().timeIntervalSince1970)
                    let rate = Rate(currencyCode: self.currency, btc: index, blockTimestamp: timestamp)
                    let method = exchangeRate.from
                    let info = ExchangeRateInfo(rate: rate, method: method)
                    buy.append(info)
                }
            }
            
            let id = object["id"].stringValue
            let rates = Rates(buy: buy, sell: sell)
            dict[id] = rates
        }
        return dict
    }
    
}
