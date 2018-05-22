//
//  Strings+Shop.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    
    enum Shop {
        static let title = NSLocalizedString("Shop.title", tableName: "Shop", value: "Spend", comment: "How to spend screen title")
        static let balanceToSpend = NSLocalizedString("Shop.balanceToSpend", tableName: "Shop", value: "Balance to spend", comment: "Balance view title")
        static let alertTitle = NSLocalizedString("Buy.alertTitle", tableName: "Shop", value: "You’re leaving Billion", comment: "Alert title")
        static let alertMessage = NSLocalizedString("Buy.alertMessage", tableName: "Shop", value: "This page will be opened in your web-browser. Use your bitcoin-address from Billion to keep your funds in a safe place.", comment: "Alert message")
        static let ok = NSLocalizedString("Buy.ok", tableName: "Shop", value: "OK", comment: "Ok button")
        static let cancel = NSLocalizedString("Buy.cancel", tableName: "Shop", value: "Cancel", comment: "Cancel button")
    }

}
