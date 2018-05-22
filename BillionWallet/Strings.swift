//
//  Strings.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum Strings {
    // Give enumeration types singular rather than plural names, so that they read as self-evident (The Swift Programming Language – Enumerations)
    
    static let satoshiSymbol = "㋛"
    
    enum Formatter {
        static let confifmationMinutesFormat = NSLocalizedString("Formatter.confifmationTime", value: "≈%@", comment: "Confifmation Time in example 10 minutes")
    }
    
    enum Balance {
        /* Sync */
        // FIXME put network statuses into separate BTCNetworkConnectionStatus enum

        static let connecting = NSLocalizedString("BitcoinNetworkConectionStatus.connecting", value: "Waiting for network", comment: "Label shown when app is waiting for network")
        static let syncing = NSLocalizedString("BitcoinNetworkConectionStatus.syncing", value: "Syncing with blockchain", comment: "Label shown when app is syncing with blockchain")
        static let synced = NSLocalizedString("BitcoinNetworkConectionStatus.synced", value: "Synced", comment: "Label shown when app was synced with blockchain")
        static let balanceAfter = NSLocalizedString("Balance.balanceAfter", value: "Balance after transaction", comment: "Account balance after current transaction")
        
        static let unlockText = NSLocalizedString("Balance.unlockText", value: "Unlock", comment: "Unlock wallet")
        static let billionText = NSLocalizedString("Balance.billionText", value: "Billion", comment: "Billion product name")
        static let unlockWithPin = NSLocalizedString("Balance.unlockWithPin", value: "with passcode", comment: "'Unlock' message tail when Touch ID/Face ID is disabled")
        static let unlockWithTouchId = NSLocalizedString("Balance.unlockWithTouchId", value: "with Touch ID", comment: "'Unlock' message tail when Touch ID is enabled")
        static let unlockWithFaceId = NSLocalizedString("Balance.unlockWithFaceId", value: "with Face ID", comment: "'Unlock' message tail when Face ID is enabled (iPhone X only)")
        static let yourBalanceText = NSLocalizedString("Balance.yourBalanceText", value: "Your balance", comment: "Your balance")
    }
    
    enum TxFailure {
        static let header = NSLocalizedString("TxFailure.header", value: "Transaction failed", comment: "Label shown when something with transaction went wrong and she failed")
    }
    
    enum QRErrors {
        static let noQrInPhoto = NSLocalizedString("QRErrors.noQrInPhoto", value: "Selected image does not contain QR-code.", comment: "Label shown when app can't recognize QR-code in provided image")
        static let noBitcoinAddress = NSLocalizedString("QRErrors.noBitcoinAddress", value: "Selected image does not contain a vaild Bitcoin address.", comment: "Label shown when selected image does not contain Bitcoin address")
    }

    enum Authentication {
        static let touchIDAuthReason = NSLocalizedString("Authentication.touchIDAuthReason", value: "Use Touch ID to authenticate." , comment: "This label shown when you unlock app with touch id")
        static let faceIDAuthReason = NSLocalizedString("Authentication.faceIDAuthReason", value: "Use Face ID to authenticate", comment: "This label shown when you unlock app with face id")
    }
    
    enum SchemeResolver {
        static let unknownUrl = NSLocalizedString("SchemeResolver.unknownUrl", value: "Unknown url" , comment: "Label shown when url doesn't opened in app")
        static let nowallet = NSLocalizedString("SchemeResolver.noWallet", value: "To proceed, please restore your wallet with a Recovery Phrase or create a new one." , comment: "Label shown when you have not wallet but you need it for processing")
    }
    
    enum TouchId {
        static let enterPasscode = NSLocalizedString("TouchId.EnterPasscode", value: "Enter Passcode", comment: "Invocation for enter passcode")
        static let authRequired = NSLocalizedString("TouchId.BiomerticAuthentication", value: "Authentication required to proceed", comment: "Invocation biomertic authentication")
    }
    
    enum OtherErrors {
        enum Fee {
            static let notLoaded = NSLocalizedString("OtherErrors.Fee.notLoaded", value: "FeeProvider did not load fee data yet", comment: "Fee provider did not yet finished loading.")
        }
        static let testnetWarning = NSLocalizedString("OtherErrors.testnetWarning", value: "WARNING! TESTNET VERSION! DO NOT SEND REAL BITCOINS TO THIS CONTACT!", comment: "Warning for testnet profiles")
    }
}

