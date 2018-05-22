//
//  Keychain+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum KeychainKeys: String {
    case pin
    case isLocked
    case selfPCPriv
}

extension Keychain {
    
    var isPinExist: Bool {
        return exist(.pin)
    }
    
    var pin: String? {
        get {
            return getString(for: .pin)
        }
        set {
            setString(newValue, for: .pin)
        }
    }
    
    var isLocked: Bool {
        get {
            return getBool(for: .isLocked)
        }
        set {
            setBool(newValue, for: .isLocked)
        }
    }
  
    var selfPCPriv: Data? {
        get {
            return getData(forKey: KeychainKeys.selfPCPriv.rawValue)
        }
        set {
            setData(newValue, forKey: KeychainKeys.selfPCPriv.rawValue)
        }
    }
    
}
