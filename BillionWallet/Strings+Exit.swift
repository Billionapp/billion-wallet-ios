//
//  Strings+Exit.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    
    enum Exit {
        static let title = NSLocalizedString("Exit.title", tableName: "Exit", value: "Exit the wallet?", comment: "Exit alert title")
        static let hint = NSLocalizedString("Exit.hint", tableName: "Exit", value: "If you not write recovery phrase you can never recover\nwallet and forever lose them", comment: "Exit alert subtitle")
        static let clearIcloud = NSLocalizedString("Exit.clearIcloud", tableName: "Exit", value: "Clear iCloud data", comment: "Clear iCloud switcher title")
        static let exitButton = NSLocalizedString("Exit.exitButton", tableName: "Exit", value: "Exit wallet", comment: "Exit button title")
        static let cancelButton = NSLocalizedString("Exit.cancelButton", tableName: "Exit", value: "Cancel", comment: "Cancel button title")
    }
    
}
