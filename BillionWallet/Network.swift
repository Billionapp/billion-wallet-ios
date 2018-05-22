//
//  Network.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//
import Foundation

enum NetworkError: LocalizedError, CustomStringConvertible {
    case unknown
    case invalidResponse
    case httpFailure(Int)
    case statusFailed
    
    var errorDescription: String? {
        return self.description
    }
    
    var description: String {
        switch self {
        case .unknown: return "An unknown error occurred"
        case .invalidResponse: return "Received an invalid response"
        case .statusFailed: return "Status Failed"
        case .httpFailure(let code): return "HTTP failure \(code)"
        }
    }
}

protocol NetworkCancelable {
    func cancel()
}
extension URLSessionDataTask: NetworkCancelable { }

protocol Network {
    func stopAllOperations()
    
    @discardableResult
    func makeRequest(_ networkRequest: NetworkRequest, resultQueue: DispatchQueue, completion: @escaping (Result<JSON>) -> Void) -> NetworkCancelable?
    @discardableResult
    func makeRequest(_ networkRequest: NetworkRequest, resultQueue: DispatchQueue, completion: @escaping (Result<Data>) -> Void) -> NetworkCancelable?
}

extension Network {
    @discardableResult
    func makeRequest(_ networkRequest: NetworkRequest, completion: @escaping (Result<JSON>) -> Void) -> NetworkCancelable? {
        return makeRequest(networkRequest, resultQueue: .main, completion: completion)
    }
    
    @discardableResult
    func makeRequest(_ networkRequest: NetworkRequest, completion: @escaping (Result<Data>) -> Void) -> NetworkCancelable? {
        return makeRequest(networkRequest, resultQueue: .main, completion: completion)
    }
}
