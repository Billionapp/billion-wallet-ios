//
//  Defaults.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

final class Defaults {
    
    var taskQueue: [TaskQueue] {
        get {
            if let data: Data = get(forKey: .taskQueue),
                let operationTypeRaw = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Int]  {
                return operationTypeRaw.flatMap {
                    guard let type = TaskQueue.OperationType(rawValue: $0) else {
                        Logger.debug("Ignoring TaskQueue value \"\($0)\"")
                        return nil
                    }
                    return TaskQueue(operationType: type)
                }
            }
 
            return [TaskQueue]()
        }
        
        set {
            let operationTypeRaw = newValue.map { $0.operationType.rawValue }
            let data = NSKeyedArchiver.archivedData(withRootObject: operationTypeRaw)
            set(value: data, forKey: .taskQueue)
        }
    }
    
    var firstLaunchDate: Date? {
        get {
            return getObject(forKey: .firstLaunchDate)
        }
        
        set {
            set(value: newValue, forKey: .firstLaunchDate)
        }
    }
    
    var isBackupRestored: Bool {
        get {
            if !getBool(forKey: .isBackupRestored) {
                set(value: true, forKey: .isBackupRestored)
                return false
            }
            return true
        }
    }
    
    var isWalletJustCreated: Bool {
        get {
            let value = getBool(forKey: .isWalletJustCreated)
            set(value: false, forKey: .isWalletJustCreated)
            return value
        }
        set {
            set(value: newValue, forKey: .isWalletJustCreated)
        }
    }
    
    var userName: String? {
        get {
            return get(forKey: .userName)
        }
        
        set {
            set(value: newValue, forKey: .userName)
        }
    }
    
    var isTouchIdEnabled: Bool {
        get {
            return getBool(forKey: .isTouchIdEnabled)
        }
        
        set {
            set(value: newValue, forKey: .isTouchIdEnabled)
            NotificationCenter.default.post(name: .didChangeIsTouchIdEnabled, object: newValue)
        }
    }
    
    var appStarted: Bool {
        get {
            return getBool(forKey: .appStarted)
        }
        set {
            set(value: newValue, forKey: .appStarted)
        }
    }
    
    /// Cannot be empty
    var currencies: [Currency] {
        get {
            if let currenciesData: Data = get(forKey: .currency),
                let currenciesRaw = NSKeyedUnarchiver.unarchiveObject(with: currenciesData) as? [String] {
                return currenciesRaw.flatMap({ CurrencyFactory.currencyWithCode($0) })
            }
            return [CurrencyFactory.defaultCurrency]
        }
        
        set {
            let currenciesRaw = newValue.map { $0.code }
            let currenciesData = NSKeyedArchiver.archivedData(withRootObject: currenciesRaw)
            set(value: currenciesData, forKey: .currency)
        }
    }
    
    var useBlockSyncIndication: Bool {
        get {
            return getBool(forKey: .useBlockSyncIndication)
        }
        set {
            set(value: newValue, forKey: .useBlockSyncIndication)
        }
    }
    
    func clear() {
        for key in Keys.allValues {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
    
    var apnsToken: Data? {
        get {
            return get(forKey: .apnsToken)
        }
        set {
            set(value: newValue, forKey: .apnsToken)
        }
    }
}

fileprivate extension Defaults {
    
    enum Keys: String, EnumCollection {
        case isTouchIdEnabled
        case currency
        case isBackupRestored
        case isWalletJustCreated
        case userName
        case userNick
        case firstLaunchDate
        case taskQueue
        case useBlockSyncIndication
        case appStarted
        case apnsToken
    }
    
    func set<T: Any>(value: T, forKey key: Keys) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func get<T: Any>(forKey key: Keys, fallback: T) -> T {
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? T {
            return value
        }
        
        return fallback
    }
    
    func getObject<T: Any>(forKey key: Keys, fallback: T) -> T {
        if let value = UserDefaults.standard.object(forKey: key.rawValue) as? T {
            return value
        }
        
        return fallback
    }
    
    func get<T: Any>(forKey key: Keys) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
    func getBool(forKey key: Keys) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }
    
    func getObject<T: Any>(forKey key: Keys) -> T? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
}

extension Notification.Name {
    static let didChangeIsTouchIdEnabled = Notification.Name("didChangeIsTouchIdEnabled")
}
