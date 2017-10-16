//
//  ApiTemplate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum APIError: Error, CustomStringConvertible {
    case invalidResponse
    case notFound
    
    var description: String {
        switch self {
        case .invalidResponse: return "Received an invalid response"
        case .notFound: return "Requested item was not found"
        }
    }
}

class API {
    // MARK: - Private
    let network: Network
    
    // MARK: - Lifecycle
    init(network: Network) {
        self.network = network
    }
}
