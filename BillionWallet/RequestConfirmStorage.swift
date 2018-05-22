//
//  RequestConfirmStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RequestConfirmStorage: MessageStorageProtocol {
    
    let requestProvider: SelfPaymentRequestProtocol
    
    init(requestProvider: SelfPaymentRequestProtocol) {
        self.requestProvider = requestProvider
    }
    
    func store(json: JSON) throws {
        guard
            let id = json["id"].string else {
                throw RequestConfirmStorageError.noIdentifier
        }
        requestProvider.deleteSelfPaymentRequest(identifier: id, completion: {
            Logger.info("Self payment request successfuly deleted")
        }) { error in
            Logger.error("Self payment request deleting error: \(error.localizedDescription)")
        }
    }
}

enum RequestConfirmStorageError: Error {
    case noIdentifier
}

