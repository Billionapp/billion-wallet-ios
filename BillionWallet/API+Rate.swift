//
//  API+Rate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension API {
    func getCurrenciesRate(completion: @escaping (Result<[Rate]>) -> Void) {
        let request = NetworkRequest(method: .GET, path: "/rates")
        
        network.makeRequest(request) {(result: Result<JSON>) in
            
            switch result {
            case .success(let json):
                guard json["status"].stringValue == "success" else {
                    let err = RatesRequestError.statusFailed
                    completion(.failure(err))
                    return
                }
                
                var outputArray = [Rate]()
                let timestamp = json["data"][0]["timestamp"].int64Value
                let ratesArray = json["data"][0]["data"].arrayValue
                
                for currency in ratesArray {
                    let btcRate = currency["rate"].doubleValue
                    let code = currency["code"].stringValue
                    
                    let rate = Rate(currencyCode: code, btc: btcRate, timestamp: timestamp)
                    outputArray.append(rate)
                }
                
                completion(.success(outputArray))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCurrenciesRateHistory(from tx: BRTransaction, completion: @escaping (Result<[Rate]>) -> Void) {
        
        let timestampInt =  UInt64(tx.timestamp+NSTimeIntervalSince1970)
        let randomFrom = UInt64(arc4random_uniform(300))
        let randomTo = UInt64(arc4random_uniform(300))
        let from = "\(timestampInt - randomFrom)"
        let to = "\(timestampInt + randomTo)"
        
        let request = NetworkRequest(method: .GET, path: "/rates/\(from)/\(to)")
        
        network.makeRequest(request) {(result: Result<JSON>) in
            
            switch result {
            case .success(let json):
                guard json["status"].stringValue == "success" else {
                    let err = RatesRequestError.statusFailed
                    completion(.failure(err))
                    return
                }
                let historyArray = json["data"].arrayValue
                var outputArray = [Rate]()
                
                var jsonStamps = [Int64]()
                for i in historyArray.enumerated() {
                    let stamp = json["data"][i.offset]["timestamp"].int64Value
                    jsonStamps.append(stamp)
                }
                
                let minDelta = jsonStamps.map{ abs($0 - Int64(timestampInt)) }.min() ?? 0
                let index = jsonStamps.index(of: Int64(timestampInt)-minDelta) ?? 0
                
                let timestamp = json["data"][index]["timestamp"].int64Value
                let ratesArray = json["data"][index]["data"].arrayValue
                for currency in ratesArray {
                    let btcRate = currency["rate"].doubleValue
                    let code = currency["code"].stringValue
                    
                    let rate = Rate(currencyCode: code, btc: btcRate, timestamp: timestamp)
                    outputArray.append(rate)
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
}

extension RatesRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .statusFailed:
            return NSLocalizedString("Status is failed", comment: "")
        }
    }
}

