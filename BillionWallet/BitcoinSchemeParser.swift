//
//  BitcoinSchemeParser.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BitcoinSchemeParserProtocol {
    func parseUrl(_ url: URL) throws -> BitcoinUrlData
}

class BitcoinSchemeParser: BitcoinSchemeParserProtocol {
    
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
    
    private func getAmount(from params: [String: String]) -> Int64? {
        guard params.count != 0 else {
            return nil
        }
        
        for (key, value) in params {
            if key == "amount" {
                return getSat(from: value)
            }
        }
        
        return nil
    }
    
    private func getSat(from btc: String) -> Int64? {
        guard let btcDouble = Double(btc) else {
            return nil
        }
        
        let satDouble = btcDouble*10e7
        return Int64(satDouble)
    }
    
    func parseUrl(_ url: URL) throws -> BitcoinUrlData {
        guard let address = url.host, address.isValidBitcoinAddress else {
            throw BitcoinSchemeParserError.InvalidAddress
        }
        
        guard let params = composeParametersDictionary(from: url.absoluteString) else {
            return BitcoinUrlData(address: address)
        }
        
        guard let amount = getAmount(from: params) else {
            return BitcoinUrlData(address: address)
        }
        
        return BitcoinUrlData(address: address, amount: amount)
    }
}

// Errors
enum BitcoinSchemeParserError: Error {
    case InvalidAddress
}

extension BitcoinSchemeParserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .InvalidAddress:
            return NSLocalizedString("Invalid bitcoin address", comment: "")
        }
    }
}
