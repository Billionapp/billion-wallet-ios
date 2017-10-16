//
//  Network.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//
import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case unknown
    case invalidResponse
    
    var description: String {
        switch self {
        case .unknown: return "An unknown error occurred"
        case .invalidResponse: return "Received an invalid response"
        }
    }
}

protocol NetworkCancelable {
    func cancel()
}
extension URLSessionDataTask: NetworkCancelable { }

protocol Network {
    @discardableResult
    func makeRequest(_ request: NetworkRequest, completion: @escaping (Result<JSON>) -> Void) -> NetworkCancelable?
    @discardableResult
    func makeRequest(_ request: NetworkRequest, completion: @escaping (Result<Data>) -> Void) -> NetworkCancelable?
}
