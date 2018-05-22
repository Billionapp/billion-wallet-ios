//
//  API+Profile.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension API {
    
    func addSelfProfile(pc: String, name: String?, completion: @escaping (Result<String>) -> Void) {
        
        let body = [
            "pc": pc,
            "name": name
        ].removeNils()
        
        let request = NetworkRequest(method: .POST, path: "/me", headers: nil, body: body)
        
        network.makeRequest(request) { (result: Result<Data>) in
            switch result {
            case .success:
                completion(.success("Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateSelfProfile(name: String?, completion: @escaping (Result<String>) -> Void) {
        
        let body = [
            "name": name
            ].removeNils()
        
        let request = NetworkRequest(method: .PUT, path: "/me", headers: nil, body: body)
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success:
                completion(.success("Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func addSelfAvatar(imageData: Data, completion: @escaping (Result<String>) -> Void) {
        
        let headers = ["Content-Type": "image/jpeg", "Content-Disposition": "inline"]
        
        let request = NetworkRequest(method: .PUT, path: "/me/image", headers: headers, data: imageData)
        
        network.makeRequest(request) { (result: Result<Data>) in
            switch result {
            case .success:
                completion(.success("Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getSelfProfile(completion: @escaping (Result<LocalUserData>) -> Void) {
        let request = NetworkRequest(method: .GET, path: "/me", headers: nil)
        
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                var avatarData: Data?
                if let avatarDataString = json.dictionaryObject?["avatar"] as? String {
                    avatarData = Data(base64Encoded: avatarDataString)
                }
                
                let name = json.dictionaryObject?["name"] as? String
                let userData = LocalUserData(name: name, imageData: avatarData)
                completion(.success(userData))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
