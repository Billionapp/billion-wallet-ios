//
//  Strings+Passcode.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Passcode {
        /* Title */
        static let createPassword = NSLocalizedString("PasscodeScreen.createPasscode", tableName: "Passcode", value: "Create Passcode", comment: "Create Passcode title")
        static let changePassword = NSLocalizedString("PasscodeScreen.changePasscode", tableName: "Passcode", value: "Change Passcode", comment: "Change Passcode title")
        static let accountLocked = NSLocalizedString("PasscodeScreen.accountLocked", tableName: "Passcode", value: "Wallet Locked", comment: "Label shown that the wallet is locked")
        
        /* Subtitle */
        static let enterPasswordFirst = NSLocalizedString("PasscodeScreen.enterPasswordFirstPrompt", tableName: "Passcode", value: "Enter Passcode", comment: "Enter Passcode title")
        static let repeatPassword = NSLocalizedString("PasscodeScreen.enterPasswordSecondPrompt", tableName: "Passcode", value: "Repeat Passcode", comment: "Repeat Passcode title")
        static let updateOldPassword = NSLocalizedString("PasscodeScreen.updateOldPasswordFirstPrompt", tableName: "Passcode", value: "Enter current Passcode", comment: "Enter current Passcode title")
        static let updateNewPassword = NSLocalizedString("PasscodeScreen.updateOldPasswordSecondPrompt", tableName: "Passcode", value: "Enter new Passcode", comment: "Enter new Passcode title")
        static let updateNewRepeat = NSLocalizedString("PasscodeScreen.updateOldPasswordThirdPrompt", tableName: "Passcode", value: "Repeat new Passcode", comment: "Repeat new Passcode title")
        static let enterPasswordLock = NSLocalizedString("PasscodeScreen.enterPasscode", tableName: "Passcode", value: "Enter Passcode", comment: "Enter Passcode title")
        
        /* Pin input */
        static let delete = NSLocalizedString("PasscodeScreen.delete", tableName: "Passcode", value: "Delete", comment: "Delete last character")
        static let cancel = NSLocalizedString("PasscodeScreen.cancel", tableName: "Passcode", value: "Cancel", comment: "Cancel passcode entering")
    }
}
