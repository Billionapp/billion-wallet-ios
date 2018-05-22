//
//  PinCodeMigratorv040.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PinCodeMigratorv040: VersionMigrator {
    
    private let keychain: Keychain
    private let lock: NSConditionLock
    private let passcodeRouter: PasscodeRouter
    
    private let lockCondition: Int = 0
    private let unlockCondition: Int = 1
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.4.0"
    
    init(keychain: Keychain, passcodeRouter: PasscodeRouter) {
        self.keychain = keychain
        self.passcodeRouter = passcodeRouter
        self.lock = NSConditionLock(condition: lockCondition)
    }
    
    func migrateData() {
        guard let pin = keychain.getString(for: .pin),
            pin != "" else {
            Logger.info("Pin is not set. Ignoring.")
            return
        }
        if pin.count == 4 {
            DispatchQueue.main.async {
                self.passcodeRouter.run(pinSize: 4, output: self)
            }
            lock.lock(whenCondition: unlockCondition)
        } else if pin.count == 6 {
            Logger.warn("Pin has already been set. Usually this can be caused by crashed migration process.")
        } else {
            fatalError("Inconsistency detected! Pin code is not of 4 or 6 symbols length!")
        }
    }
}

extension PinCodeMigratorv040: PasscodeOutputDelegate {
    func didCompleteVerification() {
        
    }
    
    func didUpdatePasscode(_ passcode: String) {
        keychain.pin = passcode
        lock.unlock(withCondition: unlockCondition)
    }
}
