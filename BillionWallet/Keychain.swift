//
//  Keychain.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Security
import Foundation

class Keychain {
    
    private let serviceName = SEC_ATTR_SERVICE
    
    private let kSecClassGenericPasswordValue = String(format: kSecClassGenericPassword as String)
    private let kSecClassValue = String(format: kSecClass as String)
    private let kSecAttrServiceValue = String(format: kSecAttrService as String)
    private let kSecValueDataValue = String(format: kSecValueData as String)
    private let kSecMatchLimitValue = String(format: kSecMatchLimit as String)
    private let kSecReturnDataValue = String(format: kSecReturnData as String)
    private let kSecMatchLimitOneValue = String(format: kSecMatchLimitOne as String)
    private let kSecAttrAccountValue = String(format: kSecAttrAccount as String)
    private let kSecAttrAccessibleValue = String(format: kSecAttrAccessible as String)
    private let kSecAttrAccessGroupValue = String(format: kSecAttrAccessGroup as String)
    
    private func set(_ data: Data, for key: String) {
        
        var query = generateQuery(for: key)
        
        SecItemDelete(query as CFDictionary)
        
        query.removeValue(forKey: kSecReturnDataValue)
        query.updateValue(data, forKey: kSecValueDataValue)
        query.updateValue(kSecAttrAccessibleAfterFirstUnlock, forKey: kSecAttrAccessibleValue)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            return
        }
    }
    
    private func get(for key: String) -> Data? {
        
        let query = generateQuery(for: key)
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            return nil
        }
        
        return data
    }
    
    private func delete(for key: String) {
        let query = generateQuery(for: key)
        SecItemDelete(query as CFDictionary)
    }
    
    private func generateQuery(for key: String) -> [String: Any] {
        return [
            kSecClassValue: kSecClassGenericPasswordValue,
            kSecAttrServiceValue: serviceName,
            kSecAttrAccountValue: key,
            kSecReturnDataValue: kCFBooleanTrue
        ]
    }
}

// MARK: - Keychain helper builders
extension Keychain {
    
    func deleteAll() {
        let query = [kSecClassValue: kSecClassGenericPasswordValue]
        SecItemDelete(query as CFDictionary)
    }
    
    func getData(forKey key: String) -> Data? {
        return get(for: key)
    }
    
    func setData(_ data: Data?, forKey key: String) {
        if let data = data {
            set(data, for: key)
        } else {
            delete(for: key)
        }
    }
    
    func getString(for key: KeychainKeys) -> String? {
        guard let data = get(for: key.rawValue),
            let value = String(data: data, encoding: .utf8) else {
                return nil
        }
        return value
    }
    
    func setString(_ value: String?, for key: KeychainKeys) {
        if let data = value?.data(using: .utf8) {
            set(data, for: key.rawValue)
        } else {
            delete(for: key.rawValue)
        }
    }
    
    func getBool(for key: KeychainKeys) -> Bool {
        guard let _ = getString(for: key) else {
            return false
        }
        return true
    }
    
    func setBool(_ value: Bool, for key: KeychainKeys) {
        setString(value ? "true" : nil, for: key)
    }
    
    func exist(_ key: KeychainKeys) -> Bool {
        return get(for: key.rawValue) != nil
    }
}
