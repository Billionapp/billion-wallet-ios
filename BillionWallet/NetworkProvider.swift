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
    var requestIndex: UInt32
    var lock: NSLock
    var activeRequests: [UInt32: URLSessionDataTask]
    
    // MARK: - Lifecycle
    init(session: URLSession = URLSession.shared) {
        self.session = session
        lock = NSLock()
        requestIndex = 0
        self.activeRequests = [:]
    }
    
    deinit {
        stopAllOperations()
    }
    
    func stopAllOperations() {
        lock.lock()
        defer {
            lock.unlock()
        }
        for (_, req) in activeRequests {
            req.cancel()
        }
        activeRequests.removeAll()
    }
    
    func getNextIndex() -> UInt32 {
        lock.lock()
        defer {
            lock.unlock()
        }
        let index = requestIndex
        requestIndex += 1
        return index
    }
    
    func addRequest(_ request: URLSessionDataTask, index: UInt32) {
        lock.lock()
        self.activeRequests[index] = request
        lock.unlock()
    }
    
    func removeRequest(index: UInt32) {
        lock.lock()
        activeRequests.removeValue(forKey: index)
        lock.unlock()
    }
    
    func cancelRequest(index: UInt32) {
        if let req = self.activeRequests[index] {
            req.cancel()
            self.removeRequest(index: index)
        }
    }
    
    // MARK: - Public
    func makeRequest(_ networkRequest: NetworkRequest, resultQueue: DispatchQueue = .main, completion: @escaping (Result<JSON>) -> Void) -> NetworkCancelable? {
        do {
            var networkRequest = networkRequest
            let request = try networkRequest.buildURLRequest()
            
            let taskIndex = self.getNextIndex()
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                self.removeRequest(index: taskIndex)
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    resultQueue.async { completion(.failure(error ?? NetworkError.unknown)) }
                    return
                }
                
                if httpResponse.statusCode == 204 {
                    resultQueue.async {
                        completion(.success(JSON.null))
                    }
                    return
                }
                
                if httpResponse.statusCode != 200 {
                    resultQueue.async {
                        completion(.failure(error ?? NetworkError.httpFailure(httpResponse.statusCode)))
                    }
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    let result = JSON(json)
                    resultQueue.async {
                        if result["status"] == "fail" {
                            completion(.failure(NetworkError.statusFailed))
                            Logger.error("Request status failed: \(result["errors"])")
                        } else {
                            completion(.success(result))
                        }
                    }
                } catch {
                    resultQueue.async {
                        completion(.failure(error))
                    }
                }
            })
            self.addRequest(task, index: taskIndex)
            task.resume()
            return task
            
        } catch let error {
            resultQueue.async {
                completion(.failure(error))
            }
            return nil
        }
    }
    
    func makeRequest(_ networkRequest: NetworkRequest, resultQueue: DispatchQueue = .main, completion: @escaping (Result<Data>) -> Void) -> NetworkCancelable? {
        do {
            var networkRequest = networkRequest
            let request = try networkRequest.buildURLRequest()
            let taskIndex = self.getNextIndex()
            let task = self.session.dataTask(with: request, completionHandler: { (data, response, error) in
                self.removeRequest(index: taskIndex)
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    resultQueue.async { completion(.failure(error ?? NetworkError.unknown)) }
                    return
                }
                
                resultQueue.async {
                    if httpResponse.statusCode == 200 {
                        completion(.success(data))
                    } else {
                        completion(.failure(error ?? NetworkError.httpFailure(httpResponse.statusCode)))
                    }
                }
            })
            self.addRequest(task, index: taskIndex)
            task.resume()
            return task
            
        } catch let error {
            completion(.failure(error))
            return nil
        }
    }
}
