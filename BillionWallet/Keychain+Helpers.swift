//
//  Keychain+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

enum KeychainKeys: String {
    case pin
    case isLocked
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
            NotificationCenter.default.post(name: .didUpdateLockStatus, object: newValue)
        }
    }
    
}

extension Notification.Name {
    static let didUpdateLockStatus = Notification.Name("didUpdateLockStatus")
}
