//
//  TxPostConfirmRequest.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TxPostConfirmRequest: TxPostPublish {
    
    let messageSendProvider: RequestSendProviderProtocol
    let requestId: String
    let contact: ContactProtocol
    
    init(messageSendProvider: RequestSendProviderProtocol, requestId: String, contact: ContactProtocol) {
        self.messageSendProvider = messageSendProvider
        self.requestId = requestId
        self.contact = contact
    }
    
    func performPostPublishTasks(_ transactions: [Transaction]) {
        messageSendProvider.confirmRequest(identifier: requestId, contact: contact) { result in
            Logger.info("Confirm request result: \(result)")
        }
    }
}
