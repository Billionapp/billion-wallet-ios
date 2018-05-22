//
//  API+Push.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension API {
    func configPush(env: String, token: String, net: String, completion: @escaping (Result<String>) -> Void) {
        let body = [
            "env": env,
            "net": net,
            "apns_token": token
        ]
        
        let request = NetworkRequest(method: .POST, path: "/apns/config", headers: nil, body: body)
        Logger.debug("\(request)")
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success:
                completion(.success("Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
  
    func subscribe(queueIds: [String], completion: @escaping (Result<String>) -> Void) {
        let body = ["ids": queueIds]
        let request = NetworkRequest(method: .POST, path: "/ms/config", body: body)
        Logger.debug("\(request)")
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
