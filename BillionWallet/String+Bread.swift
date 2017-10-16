//
//  String+Bread.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension String {
    static func base58(with data: Data) -> String {
        return NSString.base58(with: data)
    }
    
    static func base58check(with data: Data) -> String {
        return NSString.base58check(with: data)
    }
    
    static func hex(with data: Data) -> String {
        return NSString.hex(with: data)
    }
    
    static func address(withScriptPubKey scriptPubKey: Data) -> String? {
        return NSString.address(withScriptPubKey: scriptPubKey)
    }
    
    static func address(withScriptSig scriptSig: Data) -> String? {
        return NSString.address(withScriptSig: scriptSig)
    }
    
    var base58asData: Data {
        return (self as NSString).base58ToData()
    }
    
    var base58checkAsData: Data? {
        return (self as NSString).base58checkToData()
    }
    
    var hexToData: Data? {
        return (self as NSString).hexToData()
    }
    
    var addressToHash160: Data? {
        return (self as NSString).addressToHash160()
    }
    
    var isValidBitcoinAddress: Bool {
        return (self as NSString).isValidBitcoinAddress()
    }
    
    var isValidBitcoinPrivateKey: Bool {
        return (self as NSString).isValidBitcoinPrivateKey()
    }

    var isValidBitcoinBIP38Key: Bool {
        return (self as NSString).isValidBitcoinBIP38Key()
    }
}
