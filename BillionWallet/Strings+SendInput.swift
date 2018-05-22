//
//  Strings+SendInput.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum SendInput {
        static let title = NSLocalizedString("SendScreen.title", tableName: "SendInput", value: "Send", comment: "Send title")
        static let titleAmountFormat = NSLocalizedString("SendScreen.titleAmountEnetered", tableName: "SendInput", value: "Send\n%@", comment: "Amount of money which user want to send. Shown in title")
        /* Header */
        static let balanceTitle = NSLocalizedString("Send.balanceTitle", tableName: "SendInput", value: "Your balance", comment: "Your balance title")
        static let billionLocked = NSLocalizedString("SendScreen.billionLocked", tableName: "SendInput", value: "Billion", comment: "Label shown on balance button when app locked")
        
        /* Textfields */
        static let commentPlaceholder = NSLocalizedString("SendScreen.Textfield.commentPlaceholder", tableName: "SendInput", value: "Local note", comment: "placeholder for a local transaction note")
        static let amountPlaceholder = NSLocalizedString("SendScreen.Textfield.amountPlaceholder", tableName: "SendInput", value: "Enter amount", comment: "Amount of money which user want to send")
        static let viewLabelFormat = NSLocalizedString("SendScreen.Textfield.viewLabelFormat", tableName: "SendInput", value: "  %@  ", comment: "This field not translating")

        static let sendBlocked =  NSLocalizedString("SendScreen.sendBlocked", tableName: "SendInput", value: "The wallet is not\n synced with Bitcoin blockchain.\nIt might take a few minutes", comment: "Label shown that the wallet is not already synced")
    }
}
