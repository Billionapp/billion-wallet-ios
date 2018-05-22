//
//  RequestDeclineStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RequestDeclineStorage: MessageStorageProtocol {
    
    let requestProvider: SelfPaymentRequestProtocol
    
    init(requestProvider: SelfPaymentRequestProtocol) {
        self.requestProvider = requestProvider
    }
    
    func store(json: JSON) throws {
        guard
            let id = json["id"].string else {
                throw RequestDeclineStorageError.noIdentifier
        }
        requestProvider.changeStateToRejected(identifier: id, completion: {
            Logger.info("Self payment request successfuly declined")
        }) { error in
            Logger.error("Self payment request declining error: \(error.localizedDescription)")
        }
    }
}

enum RequestDeclineStorageError: Error {
    case noIdentifier
}

