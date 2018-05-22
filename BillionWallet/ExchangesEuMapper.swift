//
//  ExchangesEuMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ExchangesEuMapper: ExchangesMapperProtocol {
    
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
            let data = object["data"]
            let objectData = data["Items"].arrayValue
            let timestamp = data["timestamp"].int64Value
            var buy = [ExchangeRateInfo]()
            for item in objectData {
                let btc = item["last_price"].doubleValue
                let rate = Rate(currencyCode: currency, btc: btc, blockTimestamp: timestamp)
                let info = ExchangeRateInfo(rate: rate, method: "")
                buy.append(info)
            }
            
            let id = object["id"].stringValue
            let rates = Rates(buy: buy, sell: [])
            dict[id] = rates
        }
        
        return dict
    }
    
}
