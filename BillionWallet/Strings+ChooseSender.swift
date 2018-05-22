//
//  Strings+ChooseSender.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum ChooseSender {
        static let chooseSenderTitle = NSLocalizedString("ChooseSender.title", tableName: "ChooseSender", value: "Receive", comment: "Receive title")
        static let chooseSenderFrom = NSLocalizedString("ChooseSender.from", tableName: "ChooseSender", value: "from...", comment: "Label offers to choose a contact from who you'll receive money")
        static let chooseSenderSubtitle = NSLocalizedString("ChooseSender.subtitle", tableName: "ChooseSender", value: "Send your one-time adress to receive funds\nor make a direct request", comment: "Send your one-time adress to receive funds\nor make a direct request title")
        static let addContact = NSLocalizedString("ChooseSender.addContact", tableName: "ChooseSender", value: "Add Contact", comment: "Add Contact button title")
    }
}

