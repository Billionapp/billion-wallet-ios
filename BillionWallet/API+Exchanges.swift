//
//  API+Exchanges.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension API {
    
    func getExchanges(country: String, completion: @escaping (Result<[Exchange]>) -> Void) {
        let request = NetworkRequest(method: .GET , path: "/exchanges/\(country)")
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let data = json.arrayValue
                let exchanges = data.map { Exchange(json: $0) }
                completion(.success(exchanges))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getExchangeRates(currency: String, ids: [String], completion: @escaping (Result<[String: Rates]>) -> Void) {
        let request = NetworkRequest(method: .POST, path: "/exchanges/rates", body: ids)
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let data = json.arrayValue
                
                var dict = [String: Rates]()
                
                for object in data {
                    let objectData = object["data"]["Items"].arrayValue
                    let exchangeRates = objectData.map { ExchangeRate(json: $0) }
                    
                    var buy = [ExchangeRateInfo]()
                    var sell = [ExchangeRateInfo]()
                    
                    for exchangeRate in exchangeRates {
                        if exchangeRate.from == "BTC" {
                            guard
                                let index = Double(exchangeRate.output),
                                exchangeRate.to.range(of: currency) != nil else {
                                    continue
                            }
                            let timestamp = Int64(Date().timeIntervalSince1970)
                            let rate = Rate(currencyCode: currency, btc: index, blockTimestamp: timestamp)
                            let method = exchangeRate.to
                            let info = ExchangeRateInfo(rate: rate, method: method)
                            sell.append(info)
                        } else if exchangeRate.to == "BTC" {
                            guard
                                let index = Double(exchangeRate.input),
                                exchangeRate.from.range(of: currency) != nil else {
                                    continue
                            }
                            let timestamp = Int64(Date().timeIntervalSince1970)
                            let rate = Rate(currencyCode: currency, btc: index, blockTimestamp: timestamp)
                            let method = exchangeRate.from
                            let info = ExchangeRateInfo(rate: rate, method: method)
                            buy.append(info)
                        }
                    }
                    
                    let id = object["id"].stringValue
                    let rates = Rates(buy: buy, sell: sell)
                    dict[id] = rates
                }
                
                completion(.success(dict))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
