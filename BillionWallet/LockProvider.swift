//
//  LockProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol LockProvider {
    var isLocked: Bool { get }
    func lock()
    func autolock()
    func unlock()
}

class LockService: LockProvider {
    private let unlockPeriod: TimeInterval = 60   // 1 minute
    private let keychain: Keychain
    private var lockStatus: Bool? = nil
    
    var lastUnlockDate: Date = Date.distantPast

    init(keychain: Keychain) {
        self.keychain = keychain
    }
    
    var isLocked: Bool {
        return keychain.isLocked
    }
    
    private func shouldLock() -> Bool {
        if lastUnlockDate.addingTimeInterval(unlockPeriod) < Date() {
            return true
        }
        return false
    }
    
    func autolock() {
        if shouldLock() {
            lock()
        }
    }
    
    func lock() {
        keychain.isLocked = true
        NotificationCenter.default.post(name: .didUpdateLockStatus, object: true)
    }
    
    func unlock() {
        keychain.isLocked = false
        lastUnlockDate = Date()
        NotificationCenter.default.post(name: .didUpdateLockStatus, object: false)
    }
}

extension Notification.Name {
    static let didUpdateLockStatus = Notification.Name("didUpdateLockStatus")
}
