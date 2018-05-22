//
//  QueueIdReceiveProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class QueueIdReceiveProvider: QueueIdProviderProtocol {
    
    let accountManager: AccountManager
    
    init(accountManager: AccountManager) {
        self.accountManager = accountManager
    }
    
    func getQueueIds(for contacts: [PaymentCodeContactProtocol]) throws -> [String] {
        return contacts.flatMap { try? self.getQueueId(for: $0.uniqueValue) }
    }
    
    func getQueueId(for paymentCode: String) throws -> String {
        let pc = try PaymentCode(with: paymentCode)
        let pcPrivData = self.accountManager.getSelfCPPriv()
        let pcPriv = try PrivatePaymentCode(priv: pcPrivData)
        guard let privkey = pcPriv.ephemeralReceiveKey(from: pc, i: qKeyIndex) else {
            throw QueueIdReceiveProviderError.invalidKey
        }
        let pubKey = ECIES.privToPub(privkey)
        return pubKey.data.sha512().hex
    }
    
    func getPaymentCode(for queueId: String, contacts: [PaymentCodeContactProtocol]) throws -> String {
        // TODO: Implement queueId cache
        let filtredContact = contacts.first() { contact in
            guard let currentQueueId = try? self.getQueueId(for: contact.uniqueValue) else {
                return false
            }
            return currentQueueId == queueId
        }
        guard let contact = filtredContact else {
            throw QueueIdReceiveProviderError.noPcForQueueId
        }
        return contact.uniqueValue
    }
    
}

enum QueueIdReceiveProviderError: LocalizedError {
    case invalidKey
    case noPcForQueueId
    
    var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "Private key deriviation failed"
        case .noPcForQueueId:
            return "No payment code for queue id"
        }
    }
}

