//
//  Strings+Receive.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Receive {
        /* Header */
        static let title = NSLocalizedString("Receive.title", tableName: "Receive", value: "Payment request", comment: "Payment request title")
        static let subtitle = NSLocalizedString("Send your address to receive funds, or request an amount from contact.", comment: "Send your address to receive funds, or request an amount from contact title")
        static let yourAddress = NSLocalizedString("Receive.yourAddress", tableName: "Receive", value: "Your address", comment: "Title above your balance")
        
        static let amountRequest = NSLocalizedString("Receive.amountRequest", tableName: "Receive", value: "Amount request", comment: "request which user want to amount")
        /* Alerts */
        static let addressCopied = NSLocalizedString("ReceiveScreen.Notice.addressCopied", tableName: "Receive", value: "Your one-time Bitcoin address has been copied to clipboard", comment: "Alert shown than one-time use's Bitcoin address has been copied to clipboard")
        static let paymentRequestCopied = NSLocalizedString("ReceiveScreen.Notice.paymentRequestCopied", tableName: "Receive", value: "Payment request has been copied to clipboard", comment: "Payment request has been copied to clipboard alert")
        static let copyAddress = NSLocalizedString("Receive.copyAddress", tableName: "Receive", value: "Copy address", comment: "copy address button")
        static let copyRequest = NSLocalizedString("Receive.copyRequest", tableName: "Receive", value: "Copy payment request", comment: "Copy payment request button")
        static let requestSent = NSLocalizedString("Receive.requestSent", tableName: "Receive", value: "Payment request sent successfully", comment: "Payment request sent successfully alert")
    }
}
