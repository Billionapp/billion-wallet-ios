//
//  Strings+ChooseReceiver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum ChooseReceiver {
        static let cannotProcessFormat = NSLocalizedString("SendScreen.Notice.cannotProcess", tableName: "ChooseReceiver", value: "Cannot process message: \"%@\"", comment:"")
        static let toTitle = NSLocalizedString("SendScreen.toTitle", tableName: "ChooseReceiver", value: "to...", comment: "Label shown which contact will be receiver")
        static let scanAddress = NSLocalizedString("SendScreen.scanButton", tableName: "ChooseReceiver", value: "Scan address", comment: "Label mean that you'll scan address in QR-code")
        static let sendToAddressInClipboard = NSLocalizedString("SendScreen.sendToAddress", tableName: "ChooseReceiver", value: "Send to address in clipboard", comment: "Label shown that Address of  receiver is in clipboard")
        static let addButton = NSLocalizedString("SendScreen.addButton", tableName: "ChooseReceiver", value: "Add contact", comment: "Label mean that you can add new contact")
        static let title = NSLocalizedString("SendScreen.title", tableName: "ChooseReceiver", value: "Send", comment: "Send title")
        static let chooseRecipientSubtitle = NSLocalizedString("Send.chooseRecipientSubtitle", tableName: "ChooseReceiver", value: "Send to a contact from your address book, paste address from the clipboard or scan the QR-Code.", comment: "Label shown us different ways to send your money")
        static let noStringInClipboard = NSLocalizedString("Send.Notice.noStringInClipboard", value: "No address in clipboard", comment: "Empty clipboard alert message")
    }
}
