//
//  LockProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol LockDelegate: class {
    func didUnlock()
}

class LockProvider {
    let unlockPeriod: TimeInterval = 60   // 1 minute
    var lastUnlockDate: Date = Date.distantPast
    
    func shouldLock() -> Bool {
        if lastUnlockDate.addingTimeInterval(unlockPeriod) < Date() {
            return true
        }
        return false
    }
}

extension LockProvider: LockDelegate {
    func didUnlock() {
        lastUnlockDate = Date()
    }
}
