//
//  API+Register.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension API {
    
    enum RegistrationCase {
        case new(udid: String, walletDigest: String, ecdhPub: String)
        case newDevice(udid: String, walletDigest: String, ecdhPub: String)
        case restore(udid: String, walletDigest: String, ecdhPub: String)
        
        var method: NetworkRequest.Method {
            switch self {
            case .new:
                return .POST
            case .newDevice:
                return .PUT
            case .restore:
                return .PATCH
            }
        }
        
        var bodyData: [String: String] {
            switch self {
            case .new(let udid, let walletDigest, let ecdhPub):
                return [
                    "ecdh_public"   : ecdhPub,
                    "wallet_digest" : walletDigest,
                    "udid"          : udid
                ]
            case .newDevice(let udid, _, let ecdhPub):
                return [
                    "ecdh_public"   : ecdhPub,
                    "udid"          : udid
                ]
            case .restore(let udid, _, let ecdhPub):
                return [
                    "ecdh_public"   : ecdhPub,
                    "udid"          : udid
                ]
            }
        }
        
        var path: String {
            switch self {
            case .new:
                return "/register"
            case .newDevice(_, let walletDigest, _):
                return "/register/" + walletDigest
            case .restore(_, let walletDigest, _):
                return "/register/" + walletDigest
            }
        }
    }
    
    func registerSelfUser(with type: RegistrationCase, completion: @escaping (Result<String>) -> Void) {

        let request = NetworkRequest(method: type.method, path: type.path, body: type.bodyData)
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                
                let status = json["status"].stringValue
                
                if (status != "success") {
                    completion(.failure(NetworkError.invalidResponse))
                } else {
                    let server_ecdh_public = json["data"]["server_ecdh_public"].stringValue
                    completion(.success(server_ecdh_public))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    
    func authentificateNewUser(completion: @escaping (Result<String>) -> Void) {
        let request = NetworkRequest(method: .GET, path: "/register/echo")
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success:
                completion(.success("Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
