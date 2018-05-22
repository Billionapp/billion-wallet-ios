//
//  QueueIdSendGenerator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class QueueIdSendProvider: QueueIdProviderProtocol {
    
    let accountManager: AccountManager
    
    init(accountManager: AccountManager, contactsProvider: ContactsProvider) {
        self.accountManager = accountManager
    }
   
    func getQueueIds(for contacts: [PaymentCodeContactProtocol]) throws -> [String] {
        return contacts.flatMap { try? self.getQueueId(for: $0.uniqueValue) }
    }
    
    func getQueueId(for paymentCode: String) throws -> String {
        let pc = try PaymentCode(with: paymentCode)
        let pcPrivData = accountManager.getSelfCPPriv()
        let pcPriv = try PrivatePaymentCode(priv: pcPrivData)
        guard let key = pcPriv.ephemeralSendKey(to: pc, i: qKeyIndex) else {
            throw QueueIdSendProviderError.deriveKeyFailed
        }
        return key.data.sha512().hex
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
            throw QueueIdSendProviderError.noPcForQueueId
        }
        return contact.uniqueValue
    }

}

enum QueueIdSendProviderError: Error {
    case deriveKeyFailed
    case noPcForQueueId
}
