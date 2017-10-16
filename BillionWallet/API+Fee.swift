//
//  API+Fee.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension API {
    
    // Get list of fee to calculate custom fee for slider
    func getListForCustomFee(transactionSize: Int?, failure: @escaping (Error) -> Void, completion: @escaping ([TransactionFee]) -> Void) {
        
        let request = NetworkRequest(method: .GET, baseUrl: "https://bitcoinfees.21.co", path: "/api/v1/fees/list")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let items = json["fees"].arrayValue
                completion(items.map { TransactionFee(json: $0, transactionSize: transactionSize) })
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    // Get fee for FeeSize
    func getFee(failure: @escaping (Error) -> Void, completion: @escaping ([String:Fee]) -> Void) {
        
        let request = NetworkRequest(method: .GET, path: "/fee_analysis")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
                
            case .success(let json):
                let status = json["status"].stringValue
                guard status == "success" else {
                    failure(GetFeeError.recieveFailure)
                    return
                }
                let items = json["data"][0]["fees"].arrayValue
                completion(self.parseFee(response: items))
                
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    // Get fee for FeeSize in case when primary host is disable
    func getFeeFallBack(failure: @escaping (Error) -> Void, completion: @escaping ([String:Fee]) -> Void) {
        let request = NetworkRequest(method: .GET, baseUrl: "https://bitcoinfees.21.co", path: "/api/v1/fees/list")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
                
            case .success(let json):
                let items = json["fees"].arrayValue
                completion(self.parseFee(response: items))
            case .failure(let error):
                failure(error)
            }
        }
        
    }
}

//Parse fee
extension API {
    fileprivate func parseFee(response: [JSON]) -> [String:Fee] {
        var feeDict = [String:Fee]()
        
        for feeSize in FeeSize.all {
            switch feeSize {
            case .high:
                let info = response[response.count - 2]
                let satPerByte = info["maxFee"].intValue
                let confirmTime = info["maxMinutes"].intValue
                let fee = Fee(size: feeSize, satPerByte: satPerByte, confirmTime: confirmTime)
                feeDict[feeSize.rawValue] = fee
            case .normal:
                let info = response[response.count/2]
                let satPerByte = info["maxFee"].intValue
                let confirmTime = info["maxMinutes"].intValue
                let fee = Fee(size: feeSize, satPerByte: satPerByte, confirmTime: confirmTime)
                feeDict[feeSize.rawValue] = fee
            case .low:
                let info = response[3]
                let satPerByte = info["maxFee"].intValue
                let confirmTime = info["maxMinutes"].intValue
                let fee = Fee(size: feeSize, satPerByte: satPerByte, confirmTime: confirmTime)
                feeDict[feeSize.rawValue] = fee
            case .custom:
                continue
            }
        }
        
        return feeDict
    }
}


enum GetFeeError: Error {
    case recieveFailure
}

extension GetFeeError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .recieveFailure:
            return NSLocalizedString("Fee recieving error", comment: "")
        }
    }
}
