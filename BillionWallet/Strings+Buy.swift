//
//  Strings+Buy.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension Strings {
    
    enum Buy {
        static let buyTitle = NSLocalizedString("Buy.buyTitle", tableName: "Buy", value: "Buy", comment: "Buy price label")
        static let sellTitle = NSLocalizedString("Buy.sellTitle", tableName: "Buy", value: "Sell", comment: "Buy price label")
        static let currentTitle = NSLocalizedString("Buy.currentTitle", tableName: "Buy", value: "Current price", comment: "Current price label")
        static let alertTitle = NSLocalizedString("Buy.alertTitle", tableName: "Buy", value: "You’re leaving Billion", comment: "Alert title")
        static let alertMessage = NSLocalizedString("Buy.alertMessage", tableName: "Buy", value: "This page will be opened in your web-browser. Use your bitcoin-address from Billion to keep your funds in a safe place.", comment: "Alert message")
        static let ok = NSLocalizedString("Buy.ok", tableName: "Buy", value: "OK", comment: "Ok button")
        static let cancel = NSLocalizedString("Buy.cancel", tableName: "Buy", value: "Cancel", comment: "Cancel button")
        static let title = NSLocalizedString("Buy.title", tableName: "Buy", value: "Trade Bitcoin", comment: "Title")
        static let paymentMethod = NSLocalizedString("Buy.paymentMethod", tableName: "Buy", value: "Choose payment method", comment: "Choose payment method")
    }

}
