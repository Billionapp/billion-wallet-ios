//
//  Strings+TxDetails.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum TxDetails {
        /* Header */
        static let titleReceived = NSLocalizedString("IncomingTxTitle", tableName: "TxDetails", value: "Incoming transaction", comment: "Incoming transaction title")
        static let titleSent = NSLocalizedString("OutgoingTxTitle", tableName: "TxDetails", value: "Outgoing transaction", comment: "Outgoing transaction title")
        
        /* Bubble */
        static let byCurrentRate = NSLocalizedString("TxDetails.byCurrentRate", tableName: "TxDetails", value: "by the current rate", comment: "byCurrentRate label")
        static let addressTitleSelf = NSLocalizedString("IncomingTxSelfAddressLabel", tableName: "TxDetails", value: "your address", comment: "Receiver address on incoming transaction")
        static let addressTitleRecipient = NSLocalizedString("OutgoingTxRecipientAddressLabel", tableName: "TxDetails", value: "recipient address", comment: "Receiver address on outgoing transaction")
        static let feeTitle = NSLocalizedString("TxFeeLabel", tableName: "TxDetails", value: "transaction fee", comment: "Transcation fee label")
        static let commentTitle = NSLocalizedString("CommentLabel", tableName: "TxDetails", value: "Note", comment: "Transaction comment label")
        static let noComment = NSLocalizedString("NoComment", tableName: "TxDetails", value: "no attached notes", comment: "Comment text if no comment provided")
        static let feeLabelFormat = NSLocalizedString("FeeFormat", tableName: "TxDetails", value: "%@", comment: "Format string for transaction fee in local currency")
        static let confirmationsTextSingle = NSLocalizedString("ConfirmationsTextSingle", tableName: "TxDetails", value: "confirmation", comment: "Singular for confirmation (i.e. 1 confirmation)")
        static let confirmationTextPlural = NSLocalizedString("ConfirmationsTextPlural", tableName: "TxDetails", value: "confirmations", comment: "Plural for confirmation (i.e. 6+ confirmations)")
        
        /* Alerts */
        static let copyTxIdPopup = NSLocalizedString("Alert.txidCopied", tableName: "TxDetails", value: "Txid has been copied to clipboard", comment:"Alert displayed after txid is copied")
        static let copyAddressPopup = NSLocalizedString("Alert.addressCopied", tableName: "TxDetails", value: "Address has been copied to clipboard", comment: "Alert displayed after receiver address is copied")
    }
}
