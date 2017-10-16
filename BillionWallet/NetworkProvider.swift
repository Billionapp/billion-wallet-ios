//
//  NetworkProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

class NetworkProvider: Network {
    // MARK: - Private
    let session: URLSession
    
    // MARK: - Lifecycle
    init(session: URLSession = URLSession.shared) {
        self.session = session
        
    }
    
    // MARK: - Public
    func makeRequest(_ networkRequest: NetworkRequest, completion: @escaping (Result<JSON>) -> Void) -> NetworkCancelable? {
        do {
            let request = try networkRequest.buildURLRequest()
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    DispatchQueue.main.async { completion(.failure(error ?? NetworkError.unknown)) }
                    return
                }
                
                if httpResponse.statusCode == 204 {
                    completion(.success(JSON.null))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let result = JSON(json)
                    DispatchQueue.main.async {
                        if result["status"] == "fail" {
                            completion(.failure(error ?? NetworkError.unknown))
                        } else {
                            completion(.success(result))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            })
            task.resume()
            return task
            
        } catch let error {
            completion(.failure(error))
            return nil
        }
    }
    
    func makeRequest(_ networkRequest: NetworkRequest, completion: @escaping (Result<Data>) -> Void) -> NetworkCancelable? {
        do {
            let request = try networkRequest.buildURLRequest()
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    DispatchQueue.main.async { completion(.failure(error ?? NetworkError.unknown)) }
                    return
                }
                
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 200 {
                        completion(.success(data))
                    } else {
                        completion(.failure(error ?? NetworkError.unknown))
                    }
                }
            })
            task.resume()
            return task
            
        } catch let error {
            completion(.failure(error))
            return nil
        }
    }
}
