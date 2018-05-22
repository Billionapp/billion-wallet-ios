//
//  Strings+Settings.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Settings {
        enum General {
            /* Header */
            static let title = NSLocalizedString("Settings.General.screenTitle", tableName: "Settings", value: "Settings", comment: "Settings title")
            
            /* Menu */
            static let exitWallet = NSLocalizedString("Settings.General.exitWallet", tableName: "Settings", value: "Exit the wallet", comment: "Exit the wallet button")
            
            static let currency = NSLocalizedString("Settings.General.currency", tableName: "Settings", value: "Currency", comment: "Currency button")
            
            static let security = NSLocalizedString("Settings.General.security", tableName: "Settings", value: "Touch ID and Passcode", comment: "Touch ID and Passcode button")
            static let securityX = NSLocalizedString("Settings.General.security", tableName: "Settings", value: "Face ID and Passcode", comment: "Face ID and Passcode button")
            static let recovery = NSLocalizedString("Settings.General.recovery", tableName: "Settings", value: "Show Recovery Phrase", comment: "Show Recovery Phrase button")
            static let about = NSLocalizedString("Settings.General.about", tableName: "Settings", value: "About Billion", comment: "About Billion button")
            
            static let lock = NSLocalizedString("Settings.General.lock", tableName: "Settings", value: "Lock Billion now", comment: "Lock Billion now button")
            static let rescan = NSLocalizedString("Settings.General.rescan", tableName: "Settings", value: "Rescan wallet", comment: "Rescan wallet button")
            
            static let mnemonicTitle = NSLocalizedString("Settings.General.recoveryPhraseScreenBackButton", tableName: "Settings", value: "Back", comment: "Back button use by user when he want to go to the back screen")
        }
        
        enum Restore {
            /* Header */
            static let title = NSLocalizedString("Settings.RestoreScreen.title", tableName: "Settings", value: "Recovery phrase", comment: "Recovery phrase title")
            static let alert = NSLocalizedString("Settings.RestoreScreen.alert", tableName: "Settings", value: "Your recovery phrase is a unique combination of words. No matter how many people use Bitcoin, there will never exist two identical word-phrases.\n\nWrite it down on a good storage medium and keep it in a safe place. If you have lost access to this iPhone, recovery phrase is the only way to access your bitcoins. If somebody got access to your recovery phrase – they get access to all your bitcoins.", comment: "Label talk that user need to save recovery phrase very well and don't show it to nobody")
        }
        
        enum Password {
            /* Header */
            static let title = NSLocalizedString("Settings.Passcode.title", tableName: "Settings", value: "Touch ID and Passcode", comment: "Touch ID and Passcode title")
            static let titleTen = NSLocalizedString("Settings.Passcode.titleTen", tableName: "Settings", value: "Face ID and Passcode", comment: "Face ID and Passcode title")
            static let subtitle = NSLocalizedString("Settings.Passcode.subtitle", tableName: "Settings", value: "Set up Touch ID as authentication method or change your passcode.", comment: "Set up Touch ID as authentication method or change your passcode title")
            static let subtitleTen = NSLocalizedString("Settings.Passcode.subtitleTen", tableName: "Settings", value: "Set up Face ID as authentication method or change your passcode.", comment: "Set up Face ID as authentication method or change your passcode title")
            
            /* Menu items */
            static let touchIdSwitch = NSLocalizedString("Settings.Passcode.touchIdSwitch", tableName: "Settings", value: "Enable Touch ID", comment: "switch named Enable Touch ID")
            static let faceIDEnable = NSLocalizedString("Settings.Passcode.faceIdSwitch", tableName: "Settings", value: "Enable Face ID", comment: "switch named Enable Face ID")
            static let passwordChange = NSLocalizedString("Settings.Passcode.passwordChange", tableName: "Settings", value: "Change Passcode", comment: "Change Passcode button")
            static let back = NSLocalizedString("Settings.Passcode.backButton", tableName: "Settings", value: "Back", comment: "Back button")
            static let passwordChanged = NSLocalizedString("Settings.Passcode.passwordChanged", tableName: "Settings", value: "Password successfully changed", comment: "assword successfully changed alert")
        }
        
        enum Currency {
            /* Header */
            static let title = NSLocalizedString("Settings.CurrencyScreen.title", tableName: "Settings", value: "Currency", comment: "Currency title")
            static let subtitle = NSLocalizedString("Settings.CurrencyScreen.subtitle", tableName: "Settings", value: "Select a currency in which you would like your balance to be displayed.", comment: "Select a currency in which you would like your balance to be displayed")
            
            /* Buttons */
            static let okButton = NSLocalizedString("Settings.CurrencyScreen.okButton", tableName: "Settings", value: "Done", comment: "Done button")
            static let cancelButton = NSLocalizedString("Settings.CurrencyScreen.cancelButton", tableName: "Settings", value: "Cancel", comment: "Cancel")
        }
        
        enum About {
            /* Header */
            static let title = NSLocalizedString("Settings.AboutSrceen.title", tableName: "Settings", value: "About Billion", comment: "About Billion")
            static let twitter = NSLocalizedString("Settings.AboutSrceen.twitter", tableName: "Settings", value: "Follow on Twitter", comment: "Link to our twitter account")
            static let seedCreationTime = NSLocalizedString("Settings.AboutSrceen.seedCreationTime", tableName: "Settings", value: "Seed creation time:", comment: "Wallet creation time. Seed is a master")
            
            /* Text */
            static let versionFormat = NSLocalizedString("Settings.AboutSrceen.about", tableName: "Settings", value: "%@ (%@), %@ distribution", comment: "build number")
        }
    }
}
