//
//  Strings+AddContact.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum AddContact {
        static let title = NSLocalizedString("AddContactScreen.title", tableName: "AddContact", value: "Add Contact", comment: "Label Add Contact")
        static let subtitle = NSLocalizedString("AddContactScreen.subtitle", tableName: "AddContact", value: "Air Connectivity", comment: "Label Air Connectivity")
        static let finding = NSLocalizedString("AddContact.finding", tableName: "AddContact",  value: "Finding a nearby contact ...", comment: "Main title. Signals that contacts are being searched for.")
        static let hint = NSLocalizedString("AddContact.hint", tableName: "AddContact",  value: "To instantly add both users this mode should enabled", comment: "Hint label")
        static let scanButton = NSLocalizedString("AddContact.scanButton", tableName: "AddContact",  value: "Scan\nBillionCard", comment: "Scan Billion card button title")
    }
}
