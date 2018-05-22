
//
//  RequestCancelStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RequestCancelStorage: MessageStorageProtocol {
    
    let requestProvider: UserPaymentRequestProtocol
    
    init(requestProvider: UserPaymentRequestProtocol) {
        self.requestProvider = requestProvider
    }
    
    func store(json: JSON) throws {
        guard
            let id = json["id"].string else {
                throw RequestCancelStorageError.noIdentifier
        }
        requestProvider.changeToState(identifier: id, state: .declined, completion: {
            Logger.info("Self payment request successfuly declined")
        }) { error in
            Logger.error("Self payment request declining error: \(error.localizedDescription)")
        }
    }
}

enum RequestCancelStorageError: Error {
    case noIdentifier
}
