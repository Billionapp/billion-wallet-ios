//
//  Strings+PaymentRequestDetails.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum PaymentRequest {
        static let receiverRequest = NSLocalizedString("PaymentRequest.receiverRequest", tableName: "PaymentRequestDetails", value: "Received a payment request", comment: "Payment request status: received")
        static let requestDeclined = NSLocalizedString("PaymentRequest.requestDeclined", tableName: "PaymentRequestDetails", value: "Payment request declined", comment: "Payment request status: declined")
        static let requestInProgress = NSLocalizedString("PaymentRequest.requestInProgress", tableName: "PaymentRequestDetails", value: "Payment request in progress", comment: "Payment request status: in progress")
        static let requestRejected = NSLocalizedString("PaymentRequest.requestRejected", tableName: "PaymentRequestDetails", value: "Payment request rejected", comment: "Payment request status: rejected")
        static let sentRequestTitle = NSLocalizedString("PaymentRequest.sentRequestTitle", tableName: "PaymentRequestDetails", value: "Sent\npayment request", comment: "Self payment request details title")
        static let receiverRequestTitle = NSLocalizedString("PaymentRequest.receiverRequestTitle", tableName: "PaymentRequestDetails", value: "Received\npayment request", comment: "User payment request details title")
        static let receiverRequestDeclinedTitle = NSLocalizedString("PaymentRequest.receiverRequestDeclinedTitle", tableName: "PaymentRequestDetails", value: "Payment request\ndeclined", comment: "Declined payment request details title")
        static let confirmButtonText = NSLocalizedString("PaymentRequest.confirmButtonText", tableName: "PaymentRequestDetails", value: "Confirm", comment: "Text to appear on confirm button for request")
        static let declineButtonText = NSLocalizedString("PaymentRequest.declineButtonText", tableName: "PaymentRequestDetails", value: "Decline", comment: "Text to appear on decline button for request")
        static let cancelButtonText = NSLocalizedString("PaymentRequest.cancelButtonText", tableName: "PaymentRequestDetails", value: "Cancel", comment: "Text to appear on cancel button for request")
        static let deleteButtonText = NSLocalizedString("PaymentRequest.deleteButtonText", tableName: "PaymentRequestDetails", value: "Delete", comment: "Text to appear on delete button for request")
        static let bubbleTitle = NSLocalizedString("PaymentRequest.bubbleTitleText", tableName: "PaymentRequestDetails", value: "Payment request", comment: "Text to appear on buble title for request")
        
        /* Alerts */
        static let insufficientBalanceError = NSLocalizedString("SendScreen.Notice.insufficientBalanceError", tableName: "PaymentRequestDetails", value: "Insufficient balance", comment: "Insufficient balance alert")
    }
}
