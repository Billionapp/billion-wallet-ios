//
//  QueueIdProviderProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol QueueIdProviderProtocol {
    func getQueueIds(for contacts: [PaymentCodeContactProtocol]) throws -> [String]
    func getQueueId(for paymentCode: String) throws -> String
    func getPaymentCode(for queueId: String, contacts: [PaymentCodeContactProtocol]) throws -> String
}

extension QueueIdProviderProtocol {
    var qKeyIndex: UInt32 {
        return (1<<31)-1
    }
}
