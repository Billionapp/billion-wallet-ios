//
//  Strings+Modal.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Modal {
        static let title = NSLocalizedString("Modal.restoreWalletTitle", tableName: "Modal", value: "Restore wallet", comment: "Label shown when you already have a wallet and you can use it")
        static let placeholder = NSLocalizedString("Modal.recoveryPhrasePlaceholder", tableName: "Modal", value: "Enter recover phrase", comment: "Phrase which you enter if you want restore wallet")
        static let okButton = NSLocalizedString("Modal.buttonOk", tableName: "Modal", value: "Done", comment: "Done")
        
        static let deleteButton = NSLocalizedString("Modal.deleteButton", tableName: "Modal", value: "Delete", comment: "Delete")
        static let cancelButton = NSLocalizedString("Modal.cancelButton", tableName: "Modal", value: "Cancel", comment: "Cancel")
    }
}
