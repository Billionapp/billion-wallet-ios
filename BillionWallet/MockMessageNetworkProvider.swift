//
//  MockMessageNetworkProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class MockMessageNetworkProvider: Network {
    func stopAllOperations() {
        
    }

    enum MockNetworkError: Error {
        case unknowned
    }
    
    let queueId = "8a6db352fbf0079bf3d175162c6974c53d019592f88ef789233b2ab4b5eb0349c75417508cf663c78e2d8903b8d2fdc934e95a8b260471e9fd8eef435405bed2"
    
    /*
     {"data":{"amount":12435427,"contactID":"PM8TJLkeG6sbG6sj63SFGu9UE3orEktyQN1TyQYQVLtKFtUyuQmypS7VnEpgGGLWodbEnYqS6VT8ATxhzHsBUfqKpyQABDyTjbSFCSHtq41NBNuCuHLB","state":0,"comment":"Zdarou","identifier":"1513609514.18363","address":""},"type":"cash_request"}
     */
    let content = "eyJkYXRhIjp7ImFtb3VudCI6MTI0MzU0MjcsImNvbnRhY3RJRCI6IlBNOFRKTGtlRzZzYkc2c2o2M1NGR3U5VUUzb3JFa3R5UU4xVHlRWVFWTHRLRnRVeXVRbXlwUzdWbkVwZ0dHTFdvZGJFbllxUzZWVDhBVHhoekhzQlVmcUtweVFBQkR5VGpiU0ZDU0h0cTQxTkJOdUN1SExCIiwic3RhdGUiOjAsImNvbW1lbnQiOiJaZGFyb3UiLCJpZGVudGlmaWVyIjoiMTUxMzYwOTUxNC4xODM2MyIsImFkZHJlc3MiOiIifSwidHlwZSI6ImNhc2hfcmVxdWVzdCJ9"
    var fileNames = [
        "b60499a9e532049d0377efad870db875ff32d023"
    ]
    
    func wrapToSussessJSON(_ dictionary: [String: Any]) -> JSON {
        return JSON([
            "status": "success",
            "data": dictionary
            ])
    }
    
    @discardableResult
    func makeRequest(_ request: NetworkRequest, resultQueue: DispatchQueue = .main, completion: @escaping (Result<JSON>) -> Void) -> NetworkCancelable? {
        
        switch request.method {
        case .GET:
            let slashCount = request.path.components(separatedBy: "/").count - 1
            switch slashCount {

            case 2:
                // Get gueue
                let response = wrapToSussessJSON(["filenames": fileNames])
                resultQueue.async {
                    completion(.success(response))
                }
            case 3:
                // Get Message
                let response = wrapToSussessJSON(["content": content])
                resultQueue.async {
                    completion(.success(response))
                }
            default:
                resultQueue.async {
                    completion(.failure(MockNetworkError.unknowned))
                }
            }
            
        case .POST:
            // Get queues
            let response = wrapToSussessJSON([queueId: fileNames])
            resultQueue.async {
                completion(.success(response))
            }
            
        case .PUT:
            let response = wrapToSussessJSON(["message": "Success"])
            resultQueue.async {
                completion(.success(response))
            }
            
        case .DELETE:
            let response = wrapToSussessJSON(["message": "Success"])
            resultQueue.async {
                completion(.success(response))
            }
            
        default:
            resultQueue.async {
                completion(.failure(MockNetworkError.unknowned))
            }
        }
        
        return nil
    }
    
    @discardableResult
    func makeRequest(_ request: NetworkRequest, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Data>) -> Void) -> NetworkCancelable? {
        return nil
    }
    
}
