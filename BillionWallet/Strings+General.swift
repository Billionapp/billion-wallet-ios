//
//  Strings+General.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum General {
        /* Buttons */
        static let receive = NSLocalizedString("General.receive", tableName: "General", value: "Receive", comment: "Receive button")
        static let send = NSLocalizedString("General.send", tableName: "General", value: "Send", comment: "Send button")
        static let addContact = NSLocalizedString("General.addContact", tableName: "General", value: "Add Contact", comment: "Add Contact button title")
        
        
        /* Transaction statuses */
        // FIXME put transaction statuses into separate TxStatus enum
        // below are 6 transaction statuses
        static let txPending = NSLocalizedString("TxStatus.pending", tableName: "General", value: "Pending", comment: "unspecified error, to be depricated or specified")
        static let txInvalid = NSLocalizedString("TxStatus.invalid", tableName: "General", value: "Invalid", comment: "unspecified error, to be depricated or specified")
        static let txUnverified = NSLocalizedString("TxStatus.unverified", tableName: "General", value: "awaiting for verification", comment: "transaction is in Bitcoin network mempool")
        
        static let confirmationsFormatPlural = NSLocalizedString("TxStatus.numberOfConfirmationsPlural", tableName: "General", value: "%ld confirmations", comment: "number of transaction confirmations")
        
        static let confirmationsFormatSingle = NSLocalizedString("TxStatus.confirmationsSingle", tableName: "General", value: "%ld confirmation", comment: "number of transaction confirmations")
        
        static let txTypeOutgoing = NSLocalizedString("TxStatus.sent", tableName: "General", value: "Sent", comment: "transaction has been confirmed by Bitcoin network")
        static let txTypeIncoming = NSLocalizedString("TxStatus.received", tableName: "General", value: "Received", comment: "transaction has been confirmed by Bitcoin network")
        
        /* Lock text */
        // FIXME put app lock statuses into separate AppLockType enum
        static let pinLocked = NSLocalizedString("AppLockType.pinLocked", tableName: "General", value: "with passcode", comment: "concatenated with 'Unlock' string when Touch ID is disabled")
        static let touchIdLocked = NSLocalizedString("AppLockType.touchIdLocked", tableName: "General", value: "with Touch ID", comment: "concatenated with 'Unlock' string when Touch ID is enabled")
        static let faceIdLocked = NSLocalizedString("AppLockType.faceIdLocked", tableName: "General", value: "with Face ID", comment: "concatenated with 'Unlock' string when Face ID is enabled")
        
        /* Alerts */
        // FIXME put notices into separate Notice enum
        static let noNetwork = NSLocalizedString("General.Notice.noInternetConnection", tableName: "General", value: "Your iPhone is not connected to Internet. Please check your Wi-Fi or Cellular connection and re-open Billion.", comment:"Notice is shown while device is not connected to Internet")
    }
}
