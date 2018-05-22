//
//  Strings+AddWallet.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum AddWallet {
        /* Header */
        static let title = NSLocalizedString("AddWallet.title", tableName: "AddWallet", value: "Add wallet", comment: "Add wallet title")
        
        /* Buttons */
        static let createWallet = NSLocalizedString("AddWallet.createWallet", tableName: "AddWallet", value: "Create new wallet", comment: "Label shown when you can to  create a new wallet")
        static let restoreWallet = NSLocalizedString("AddWallet.restoreWallet", tableName: "AddWallet", value: "Restore wallet", comment: "Label shown when you already have a wallet and you can use it")
        
        static let next = NSLocalizedString("AddWallet.nextButton", tableName: "AddWallet", value: "Next", comment: "Label shown when you need to continue the process of creating new wallet")
    }
}
