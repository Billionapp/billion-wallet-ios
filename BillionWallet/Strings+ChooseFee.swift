//
//  Strings+ChooseFee.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum ChooseFee {
        static let title = NSLocalizedString("FeeScreen.title", tableName: "ChooseFee", value: "Bitcoin Network Fee", comment: "Bitcoin Network fee title")
        static let subtitle = NSLocalizedString("FeeScreen.subtitle", tableName: "ChooseFee", value: "Set the desired network fee. Decrease the fee\nif the transaction is not time sensitive.", comment: "Label shown when you choose network fee")
        static let cancel = NSLocalizedString("FeeScreen.cancel", tableName: "ChooseFee", value: "Cancel", comment: "Cancel button title")
        
        /* Text */
        static let confirmationTimeLabel = NSLocalizedString("Fee.confirmationTimeLabel", tableName: "ChooseFee", value: "confirm time", comment: "Label shown how long transaction goes")
        static let feeTotalAmountLabel = NSLocalizedString("Fee.feeTotalAmountLabel", tableName: "ChooseFee", value: "total fee", comment: "Label shown commission for transaction")
        static let feeSatPerByteFormat = NSLocalizedString("Fee.feeSatPerByteFormat", tableName: "ChooseFee", value: "%@/byte", comment: "Transaction preority in satoshi in byte")
        
        static let transactionFailedFormat = NSLocalizedString("Fee.transactionFailedFormat", tableName: "ChooseFee", value: "Transaction failed to publish, reason: %@", comment: "Label shown when transaction failed, also show the reason of failed")
        
        static let receiver = NSLocalizedString("ChooseFee.receiver", tableName: "ChooseFee", value: "receiver: %@", comment: "Receiver of the payment")
        static let sendAmount = NSLocalizedString("ChooseFee.sendAmount", tableName: "ChooseFee", value: "Send %@", comment: "Send {amount to send}")
        static let reason = NSLocalizedString("ChooseFee.reason", tableName: "ChooseFee", value: "%@\n\n\namount: %@ (%@)\nfees: %@ (%@)\ntotal: %@ (%@)", comment: "Transfer checkout format")
    }
}
