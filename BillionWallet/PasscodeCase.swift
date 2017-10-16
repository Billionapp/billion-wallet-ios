//
//  PasscodeCase.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

enum PasscodeCase {
    case createFirst
    case createSecond(lastPasscode: String)
    case updateOld
    case updateNewFirst
    case updateNewSecond(lastPasscode: String)
    case lock
    case custom(title: String, subtitle: String)
    
    var title: String {
        switch self {
        case .createFirst, .createSecond:
            return "Create password"
        case .updateOld, .updateNewFirst, .updateNewSecond:
            return "Change password"
        case .lock:
            return "Account locked"
        case .custom(let title, _):
            return title
        }
    }
    
    var subtitle: String {
        switch self {
        case .createFirst:
            return "Enter password"
        case .createSecond:
            return "Repeat password"
        case .updateOld:
            return "Enter old password"
        case .updateNewFirst:
            return "Enter new password"
        case .updateNewSecond:
            return "Repeat new password"
        case .lock:
            return "Enter password"
        case .custom(_, let subtitle):
            return subtitle
        }
    }
    
    var showTouchId: Bool {
        switch self {
        case .lock:
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
        case .updateOld:
            let keychain = Keychain()
            return keychain.pin == code
        case .updateNewFirst:
            return true
        case .updateNewSecond(let lastPasscode):
            return lastPasscode == code
        case .lock, .custom:
            let keychain = Keychain()
            return code == keychain.pin
        }
    }
    
}

