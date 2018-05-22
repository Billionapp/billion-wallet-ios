//
//  Strings+Profile.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Profile {
        /* Profile */
        static let enterNick = NSLocalizedString("Profile.aliasBlancTextFieldLabel", tableName: "Profile", value: "Enter your alias or name", comment: "Text that's visible in a textfield that corresponds to Alias label prior to selection and typing")
        static let name = NSLocalizedString("Profile.name", tableName: "Profile", value: "Name:", comment: "After that label user entering name")
        
        /* Alerts */
        static let pcCopied = NSLocalizedString("Profile.Notice.pcCopied", tableName: "Profile", value: "Your payment code has been copied to clipboard.", comment: "Label shown that payment code has been copied to clipboard")
        static let paymentCodeString = NSLocalizedString("Profile.paymentCodeString", tableName: "Profile", value: "Payment code", comment: "Payment code title")
    }
}
