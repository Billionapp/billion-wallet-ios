//
//  NetworkRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum NetworkRequestError: Error, CustomStringConvertible {
    case invalidURL(String)
    case serializationRequestBodyError
    
    var description: String {
        switch self {
        case .invalidURL(let url): return "The url '\(url)' was invalid"
        case .serializationRequestBodyError:
            return "Serialization request body error"
        }
    }
}

struct NetworkRequest {
    // MARK: - HTTP Methods
    enum Method: String {
        case GET        = "GET"
        case PUT        = "PUT"
        case PATCH      = "PATCH"
        case POST       = "POST"
        case DELETE     = "DELETE"
    }
    
    let defaultBaseUrl = "https://devapi.digitalheroes.tech"
    
    // MARK: - Public Properties
    let method: NetworkRequest.Method
    let baseUrl: String?
    let path: String
    let headers: [String: String]?
    let body: [String: Any]?
    let data: Data?
    
    let authManager = AuthManager()
    
    init(method: NetworkRequest.Method, baseUrl: String? = nil, path: String, headers: [String:String]? = nil, body: [String: Any]? = nil, data: Data? = nil) {
        self.method = method
        self.baseUrl = baseUrl
        self.path = path
        self.headers = headers
        self.body = body
        self.data = data
    }
    
    // MARK: - Public Functions
    func buildURLRequest() throws -> URLRequest {
        let urlString = baseUrl ?? defaultBaseUrl
        guard let url = URL(string: urlString + path) else {
            throw NetworkRequestError.invalidURL(urlString + path)
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = self.method.rawValue
        
        if let headersDict = headers {
            for (key, value) in headersDict {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let bodyDict = body {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyDict), var jsonDataString = String(data: jsonData, encoding: .utf8) else {
                throw NetworkRequestError.serializationRequestBodyError
            }

            jsonDataString = jsonDataString.replacingOccurrences(of: "\\/", with: "/")
            request.httpBody = jsonDataString.data(using: .utf8 )
            
        } else if let data = data {
            request.httpBody =  data
        }
        
        if path.contains("register"), let authHeaders = authManager.getRegisterHeader(for: self) {
            for header in authHeaders {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        } else if let authHeaders = authManager.getAuthHeader(for: self) {
            for header in authHeaders {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        return request as URLRequest
    }
}
