//
//  API+FindUser.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension API {
    func findUser(nickname: String, completion: @escaping (Result<UserData>) -> Void) {
        
        let request = NetworkRequest(method: .GET, path: "/users?nick=\(nickname)")
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                guard let userData = UserData(json: json) else {
                    completion(.failure(UserData.UserDataError.parsingError))
                    return
                }
                completion(.success(userData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
