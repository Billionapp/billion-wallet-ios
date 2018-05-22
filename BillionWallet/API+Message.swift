//
//  API+Message.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension API {
    
    func getQueues(queueIds: [String], completion: @escaping (Result<[MessageQueue]>) -> Void) {
        let body = ["ids": queueIds]
        let request = NetworkRequest(method: .POST, path: "/queues", body: body)
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let object = json["data"]
                let messageQueues = object.compactMap { MessageQueue(object: $0) }
                completion(.success(messageQueues))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func sendMessage(queueId: String, fileName: String, contentString: String, sendPush: Bool, completion: @escaping (Result<String>) -> Void) {
        let body = ["content": contentString]
        let request = NetworkRequest(method: .PUT, path: "/queue/\(queueId)/\(fileName)", body: body)
        network.makeRequest(request) { (result: Result<JSON>) in
            switch result {
            case .success:
                completion(.success("Success"))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getMessage(queueId: String, fileName: String, queue: DispatchQueue, completion: @escaping (Result<Data>) -> Void) {
        let request = NetworkRequest(method: .GET, path: "/queue/\(queueId)/\(fileName)")
        network.makeRequest(request, resultQueue: queue) { (result: Result<JSON>) in
            switch result {
            case .success(let json):
                let content = json["data"].dictionaryValue
                guard
                    let stringValue = content["content"]?.stringValue,
                    let data = Data(base64Encoded: stringValue) else {
                        completion(.failure(QueueHandlerError.invalidStructure))
                        return
                }
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func deleteMessage(queueId: String, fileName: String, completion: @escaping (Result<String>) -> Void) {
        let request = NetworkRequest(method: .DELETE, path: "/queue/\(queueId)/\(fileName)")
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
