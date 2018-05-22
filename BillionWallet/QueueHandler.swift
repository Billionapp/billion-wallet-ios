//
//  QueueHandler.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class QueueHandler: QueueHandlerProtocol {
    
    let api: API
    let contactsProvider: ContactsProvider
    let queueIdProvider: QueueIdProviderProtocol
    let storage: MessageStorageManagerProtocol
    let wrapper: MessageWrapperProtocol
    let accountManager: AccountManager
    
    init(api: API, queueIdProvider: QueueIdProviderProtocol, storage: MessageStorageManagerProtocol, wrapper: MessageWrapperProtocol, contactsProvider: ContactsProvider, accountManager: AccountManager) {
        self.api = api
        self.queueIdProvider = queueIdProvider
        self.storage = storage
        self.wrapper = wrapper
        self.contactsProvider = contactsProvider
        self.accountManager = accountManager
    }
    
    func handleQueue(_ messageQueue: MessageQueue, queue: DispatchQueue) {
        for fileName in messageQueue.filenames {
            api.getMessage(queueId: messageQueue.queueId, fileName: fileName, queue: queue) { [unowned self] result in
                switch result {
                case .success(let data):
                    do {
                        try self.handleMessageData(data, queueId: messageQueue.queueId)
                        self.markMessageAsRead(queueId: messageQueue.queueId, filename: fileName)
                    } catch let error {
                        Logger.error("Message resolving failed with error. \(error.localizedDescription). Removing message...")
                        self.markMessageAsRead(queueId: messageQueue.queueId, filename: fileName)
                    }
                case .failure(let error):
                    Logger.error("Get messages failed with: \(error.localizedDescription). Removing message...")
                    self.markMessageAsRead(queueId: messageQueue.queueId, filename: fileName)
                }
            }
        }
    }
    
}

// MARK: Privates

extension QueueHandler {
    
    private func handleMessageData(_ data: Data, queueId: String) throws {
        let contacts = contactsProvider.paymentCodeProtocolContacts
        let paymentCode = try queueIdProvider.getPaymentCode(for: queueId, contacts: contacts)
        
        let bobPC = try PaymentCode(with: paymentCode)
        let selfPc = accountManager.getSelfCPPriv()
        let alicePC = try PrivatePaymentCode(priv: selfPc)
        let decryptor = MessageEncryptorFactory().create(alicePC: alicePC, bobPC: bobPC)
        
        let decoded = try decryptor.decrypt(data: data)
        let messageInfo = try wrapper.unwrap(decoded)
        try self.storage.store(type: messageInfo.type, json: messageInfo.json, paymentCode: paymentCode)
    }
    
    private func markMessageAsRead(queueId: String, filename: String) {
        api.deleteMessage(queueId: queueId, fileName: filename, completion: { result in
            switch result {
            case .success:
                Logger.info("Message \(filename) readed")
            case .failure(let error):
                Logger.error("Cannot read message \(filename). Error: \(error.localizedDescription)")
            }
        })
    }
    
}

enum QueueHandlerError: LocalizedError {
    case invalidStructure
    
    var errorDescription: String? {
        switch self {
        case .invalidStructure:
            return "Invalid response structure"
        }
    }
}
