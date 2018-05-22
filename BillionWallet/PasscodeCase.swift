//
//  PasscodeCase.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

enum PasscodeCase {
    
    typealias LocalizedStrings = Strings.Passcode
    
    case createFirst
    case createSecond(lastPasscode: String)
    case updateOld
    case migrate(pinSize: Int)
    case migrateUpdateFirst
    case migrateUpdateSecond(newPasscode: String)
    case updateNewFirst
    case updateNewSecond(lastPasscode: String)
    case lock
    case custom(title: String, subtitle: String)
    
    var title: String {
        switch self {
        case .createFirst, .createSecond:
            return LocalizedStrings.createPassword
        case .updateOld, .updateNewFirst, .updateNewSecond, .migrate, .migrateUpdateFirst, .migrateUpdateSecond:
            return LocalizedStrings.changePassword
        case .lock:
            return LocalizedStrings.accountLocked
        case .custom(let title, _):
            return title
        }
    }
    
    var subtitle: String {
        switch self {
        case .createFirst:
            return LocalizedStrings.enterPasswordFirst
        case .createSecond:
            return LocalizedStrings.repeatPassword
        case .updateOld, .migrate:
            return LocalizedStrings.updateOldPassword
        case .updateNewFirst, .migrateUpdateFirst:
            return LocalizedStrings.updateNewPassword
        case .updateNewSecond, .migrateUpdateSecond:
            return LocalizedStrings.updateNewRepeat
        case .lock:
            return LocalizedStrings.enterPasswordLock
        case .custom(_, let subtitle):
            return subtitle
        }
    }
    
    var showTouchId: Bool {
        switch self {
        case .lock, .custom:
            return true
        default:
            return false
        }
    }
    
    func verify(code: String) -> Bool {
        switch self {
        case .createFirst:
            return true
        case .createSecond(let lastValue):
            return lastValue == code
        case .updateOld, .migrate:
            let keychain = Keychain()
            return keychain.pin == code
        case .updateNewFirst, .migrateUpdateFirst:
            return true
        case .updateNewSecond(let lastPasscode):
            return lastPasscode == code
        case .migrateUpdateSecond(let newPasscode):
            return newPasscode == code
        case .lock, .custom:
            let keychain = Keychain()
            return code == keychain.pin
        }
    }
    
}

