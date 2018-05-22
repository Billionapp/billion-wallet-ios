//
//  API+Fee.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension API {
    // Get fee for FeeSize
    func getFee(failure: @escaping (Error) -> Void, completion: @escaping (JSON) -> Void) {
        let request = NetworkRequest(method: .GET, path: "/fee_analysis")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
                
            case .success(let json):
                guard json["status"].stringValue == "success" else {
                    failure(GetFeeError.recieveFailure)
                    return
                }
                let data = json["data"][0]
                completion(data)
                
            case .failure(let error):
                failure(error)
            }
        }
    }
    
    // Get fee for FeeSize in case when primary host is disable
    func getFeeFallBack(failure: @escaping (Error) -> Void, completion: @escaping (JSON) -> Void) {
        let request = NetworkRequest(method: .GET, baseUrl: "https://bitcoinfees.21.co", path: "/api/v1/fees/list")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
                
            case .success(let json):
                completion(json)
                
            case .failure(let error):
                failure(error)
            }
        }
        
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
