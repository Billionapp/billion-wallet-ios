//
//  Strings+NotificationDetails.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum NotificationDetails {
        static let networkFee = NSLocalizedString("NetworkFee", tableName: "NotificationDetails", value: "Network fee", comment: "Network fee title on the buble")
        static let privateConnection = NSLocalizedString("PrivateConnection", tableName: "NotificationDetails", value: "for private connection", comment: "commission for private connection")
        static let blockchain = NSLocalizedString("Blockchain", tableName: "NotificationDetails", value: "Blockchain", comment: "Blockchain")
        static let title = NSLocalizedString("Title", tableName: "NotificationDetails", value: "Notification transaction", comment: "Notification transaction title")
        static let subtitle = NSLocalizedString("Subtitle", tableName: "NotificationDetails", value: "Blockchain network fee for private connection", comment: "Blockchain network fee for private connection title")
        static let confirmations = NSLocalizedString("NotificationDetails.confirmations", tableName: "NotificationDetails", value: "Confirmations", comment: "Confirmations label count")
        
        /* Alerts */
        static let copyNotifyTxIdPopup = NSLocalizedString("Alert.txidCopied", tableName: "NotificationDetails", value: "Txid was copied to the clipboard", comment: "notice displayed after txid is copied")
    }
}
