//
//  Strings+TxFailureDetails.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum TxFailureDetails {
        /* Header */
        static let title = NSLocalizedString("TxFailureDetails.title", tableName: "TxFailureDetails", value: "Sending failed", comment: "Screen title for failure transcation details")
        static let titleSent = NSLocalizedString("OutgoingTxTitle", tableName: "TxFailureDetails", value: "Outgoing transaction", comment: "Outgoing transaction title")
        static let retry = NSLocalizedString("TxFailureDetails.retry", tableName: "TxFailureDetails", value: "Retry", comment: "Retry transaction")
        static let delete = NSLocalizedString("TxFailureDetails.delete", tableName: "TxFailureDetails", value: "Delete", comment: "Delete transaction")
        
        /* Bubble */
        static let byCurrentRate = NSLocalizedString("TxFailureDetails.byCurrentRate", tableName: "TxFailureDetails", value: "by the current rate", comment: "byCurrentRate label")

        static let feeTitle = NSLocalizedString("FeeLabel", tableName: "TxFailureDetails", value: "transaction fee", comment: "static text below fee label")
        static let feeLabelFormat = NSLocalizedString("FeeValueFormat", tableName: "TxFailureDetails", value: "%@ (%@)", comment: "Transaction fee format string in local currency (i.e. 9000 HK$ (100000 sat))")
        static let addressTitle = NSLocalizedString("AddressTitle", tableName: "TxFailureDetails", value: "recipient address", comment: "Receiver address on outgoing transaction")
        static let confirmations = NSLocalizedString("TxFailureDetails.confirmations", tableName: "TxFailureDetails", value: "Confirmations", comment: "Confirmations count label")
        
        /* Alert */
        static let copyAddressPopup = NSLocalizedString("Alert.addressCopied", tableName: "TxFailureDetails", value: "Address has been copied to clipboard", comment: "Alert displayed after receiver address is copied")
    }
}
