//
//  BillionSchemeParser.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BillionSchemeParserProtocol {
     func parseUrl(_ url: URL) throws -> BillionUrlData
}

class BillionSchemeParser: BillionSchemeParserProtocol {
    
    private func composeParametersDictionary(from urlString: String) -> [String: String]? {
        guard let queryItems = URLComponents(string: urlString)?.queryItems else {
            return nil
        }
        
        var parameters = [String : String]()
        
        for item in queryItems {
            parameters[item.name] = item.value
        }
        
        return parameters
    }
    
    private func getContactName(from params: [String:String]) -> String? {
        guard params.count != 0 else {
            return nil
        }
        
        for (key, value) in params {
            if key == "name" {
                return value
            }
        }
        
        return nil
    }
    
    private func getPaymentCode(from path: String) -> String? {
        guard !path.isEmpty else {
            return nil
        }
        
        let pc = String(path.dropFirst())
        
        guard let _ = try? PaymentCode(with: pc) else {
            return nil
        }
        return pc
    }
    
    private func isValidHost(url: URL) -> Bool {
        guard let host = url.host, host == "contact" else { return false }
        return true
    }

    
    func parseUrl(_ url: URL) throws -> BillionUrlData {
        guard isValidHost(url: url) else {
            throw BillionSchemeParserError.InvalidLink
        }
        
        guard let pc = getPaymentCode(from: url.path) else {
            throw BillionSchemeParserError.InvalidLink
        }
        
        guard let params = composeParametersDictionary(from: url.absoluteString) else {
            throw BillionSchemeParserError.InvalidLink
        }
        
        guard let name = getContactName(from: params) else {
            throw BillionSchemeParserError.InvalidLink
        }
        
        return BillionUrlData(pc: pc, name: name)
    }
}

//Errors
enum BillionSchemeParserError: Error {
    case InvalidLink
}

extension BillionSchemeParserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .InvalidLink:
            return NSLocalizedString("Link is incorrect", comment: "")
        }
    }
}
