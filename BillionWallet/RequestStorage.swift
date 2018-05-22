//
//  RequestStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RequestStorage: MessageStorageProtocol {
    
    let requestProvider: UserPaymentRequestProtocol
    
    init(requestProvider: UserPaymentRequestProtocol) {
        self.requestProvider = requestProvider
    }
    
    func store(json: JSON) throws {
        let jsonString = json.description
        let request = try requestProvider.restore(from: jsonString)
        if requestProvider.isRequestExist(identifier: request.identifier) {
            deleteRequest(request)
            createRequest(request)
        } else {
            createRequest(request)
        }
    }
    
}

// MARK: Privates

extension RequestStorage {
    
    private func deleteRequest(_ request: UserPaymentRequest) {
        requestProvider.deleteUserPaymentRequest(identifier: request.identifier, completion: {
            Logger.info("User payment request successfuly deleted")
        }) { error in
            Logger.error("User payment request deleteng failed with \(error)")
        }
    }
    
    private func createRequest(_ request: UserPaymentRequest) {
        requestProvider.createUserPaymentRequest(identifier: request.identifier, state: request.state, address: request.address, amount: request.amount, comment: request.comment, contactID: request.contactID ?? "", completion: {
            Logger.info("User payment request successfuly saved")
        }) { error in
            Logger.error("User payment request saving failed with \(error)")
        }
    }
    
}
