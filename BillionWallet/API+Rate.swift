//
//  API+Rate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension API {
    func getCurrenciesRate(supportedRates: [String], completion: @escaping (Result<[Rate]>) -> Void) {
        let request = NetworkRequest(method: .GET, path: "/rates")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            
            switch result {
            case .success(let json):
                guard json["status"].stringValue == "success" else {
                    completion(.failure(RatesRequestError.statusFailed))
                    return
                }
                guard let rates = json["data"].arrayValue.first?["data"].arrayValue else {
                    completion(.failure(RatesRequestError.notFound))
                    return
                }
                
                var outputArray = [Rate]()
                
                for rate in rates {
                    let code = rate["code"].stringValue
                    let value = rate["rate"].doubleValue
                    let timestamp = Int64(Date().timeIntervalSince1970)
                    if supportedRates.contains(code) {
                        let outputRate = Rate(currencyCode: code, btc: value, blockTimestamp: timestamp)
                        outputArray.append(outputRate)
                    }
                }
                
                guard !outputArray.isEmpty else {
                    completion(.failure(RatesRequestError.ratesArrayEmpty))
                    return
                }
                
                completion(.success(outputArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCurrenciesRateFallback(supportedRates: [String], completion: @escaping (Result<[Rate]>) -> Void) {
        let request = NetworkRequest(method: .GET, baseUrl: "https://bitpay.com/api", path: "/rates")
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                var outputArray = [Rate]()
                let ratesArray = json.arrayValue
                for currency in ratesArray {
                    let code = currency["code"].stringValue
                    let value = currency["rate"].doubleValue
                    let timestamp = Int64(Date().timeIntervalSince1970)
                    if supportedRates.contains(code) {
                        let outputRate = Rate(currencyCode: code, btc: value, blockTimestamp: timestamp)
                        outputArray.append(outputRate)
                    }
                }
                
                completion(.success(outputArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getHistoricalRate(supportedRates: [String], timestamp: Int64, completion: @escaping (Result<[Rate]>) -> Void) {
        let from = timestamp - 60
        let to = timestamp + 40
        let request = NetworkRequest(method: .GET, path: "/rates/\(from)/\(to)")
        
        network.makeRequest(request) { (result: Result<JSON>) in
        
            switch result {
            case .success(let json):
                guard json["status"].stringValue == "success" else {
                    completion(.failure(RatesRequestError.statusFailed))
                    return
                }
                guard let rates = json["data"].arrayValue.first?["data"].arrayValue else {
                    completion(.failure(RatesRequestError.notFound))
                    return
                }
                
                var outputArray = [Rate]()
                
                for rate in rates {
                    let code = rate["code"].stringValue
                    let value = rate["rate"].doubleValue
                    if supportedRates.contains(code) {
                        let outputRate = Rate(currencyCode: code, btc: value, blockTimestamp: timestamp)
                        outputArray.append(outputRate)
                    }
                }
                
                guard !outputArray.isEmpty else {
                    completion(.failure(RatesRequestError.ratesArrayEmpty))
                    return
                }
                
                completion(.success(outputArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
public enum RatesRequestError: Error {
    case statusFailed
    case notFound
    case ratesArrayEmpty
}

extension RatesRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .statusFailed:
            return NSLocalizedString("Status is failed", comment: "")
        case .notFound:
            return NSLocalizedString("Rates not found", comment: "")
        case .ratesArrayEmpty:
            return NSLocalizedString("Rates array is empty", comment: "")
        }
    }
}

