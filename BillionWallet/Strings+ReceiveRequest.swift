//
//  Strings+ReceiveRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum ReceiveRequest {
        static let amountPlaceholder = NSLocalizedString("ReceiveRequest.amountPlaceholder", tableName: "ReceiveRequest", value: "Enter amount", comment: "Enter amount title")
        static let balanceTitle = NSLocalizedString("ReceiveRequest.balanceTitle", tableName: "ReceiveRequest", value: "Your balance", comment: "Label show balance of the user")
        static let viewLabelFormat = NSLocalizedString("ReceiveRequest.viewLabelFormat", tableName: "ReceiveRequest", value: "  %@  ", comment: "This field not translating")
        static let commentPlaceholder = NSLocalizedString("ReceiveRequest.commentPlaceholder", tableName: "ReceiveRequest", value: "Local note", comment: "placeholder for a local transaction note")
        static let receiveTitle = NSLocalizedString("ReceiveRequest.receiveTitle", tableName: "ReceiveRequest", value: "Payment request", comment: "Payment request title")
        static let receiveTitleAmountFormat = NSLocalizedString("ReceiveRequest.receiveTitleAmountFormat", tableName: "ReceiveRequest", value: "Payment request\n%@", comment: "Label shown an amount of payment request")
        static let receiverTitle = NSLocalizedString("ReceiveRequest.receiverTitle", tableName: "ReceiveRequest", value: "Receiver:", comment: "Receiver label shown an passcode and touchID")
        static let amountTitle = NSLocalizedString("ReceiveRequest.amountTitle", tableName: "ReceiveRequest", value: "amount:", comment: "Amount label shown an passcode and touchID")
    }
}
