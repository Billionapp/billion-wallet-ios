//
//  MessageSender.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MessageSender: MessageSenderProtocol {
    
    private let api: API
    private let queueIdSendProvider: QueueIdProviderProtocol
    private let accountManager: AccountManager
    
    init(api: API, queueIdSendProvider: QueueIdProviderProtocol, accountManager: AccountManager) {
        self.api = api
        self.queueIdSendProvider = queueIdSendProvider
        self.accountManager = accountManager
    }
    
    func sendMessage(with data: Data, to contact: ContactProtocol, sendPush: Bool, completion: @escaping (Result<String>) -> Void) {
        do {
            let queueId = try queueIdSendProvider.getQueueId(for: contact.uniqueValue)
            let fileName = data.sha1().hex
            
            let bobPC = try PaymentCode(with: contact.uniqueValue)
            let selfPc = accountManager.getSelfCPPriv()
            let alicePC = try PrivatePaymentCode(priv: selfPc)
            let encryptor = MessageEncryptorFactory().create(alicePC: alicePC, bobPC: bobPC)
            
            let content = try encryptor.encrypt(data: data)
            api.sendMessage(queueId: queueId, fileName: fileName, contentString: content.base64EncodedString(), sendPush: sendPush, completion: completion)
        } catch let error {
            completion(.failure(error))
        }
    }

}

enum MessageSenderError: LocalizedError {
    case invalidContent
    
    var errorDescription: String? {
        return "Couldn't represent data as utf8 string"
    }
}
