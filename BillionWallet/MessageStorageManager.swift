//
//  MessageStorageManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MessageStorageManager: MessageStorageManagerProtocol {

    let userPaymentRequestProvider: UserPaymentRequestProtocol
    let selfPaymentRequestProvider: SelfPaymentRequestProtocol
    
    private lazy var storages: [MessageType: MessageStorageProtocol] = {
        var storages: [MessageType: MessageStorageProtocol] = [:]
        storages[.request] = RequestStorage(requestProvider: userPaymentRequestProvider)
        storages[.declineRequest] = RequestDeclineStorage(requestProvider: selfPaymentRequestProvider)
        storages[.cancelRequest] = RequestCancelStorage(requestProvider: userPaymentRequestProvider)
        storages[.confirmRequest] = RequestConfirmStorage(requestProvider: selfPaymentRequestProvider)
        return storages
    }()
    
    init(userPaymentRequestProvider: UserPaymentRequestProtocol,
         selfPaymentRequestProvider: SelfPaymentRequestProtocol) {
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
    }
    
    func store(type: MessageType, json: JSON, paymentCode: String) throws {
        guard let storage = storages[type] else {
            throw MessageStorageManagerError.notImplemented
        }
        try storage.store(json: json)
    }
    
}

enum MessageStorageManagerError: LocalizedError {
    case notImplemented
    
    var errorDescription: String? {
        return "Message type is not implemented"
    }
}
