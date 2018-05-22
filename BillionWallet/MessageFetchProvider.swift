//
//  MessageFetchProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MessageFetchProvider: MessageFetchProviderProtocol {
    
    private let api: API
    private let queueHandler: QueueHandlerProtocol
    private let queueIdProvider: QueueIdProviderProtocol
    private let contactsProvider: ContactsProvider
    
    private let timeout = 10
    private let fetchQueue = DispatchQueue(label: "MessageFetchProviderQueue")
    private var timer: DispatchSourceTimer?
    
    init(api: API, queueHandler: QueueHandler, queueIdProvider: QueueIdProviderProtocol, contactsProvider: ContactsProvider) {
        self.api = api
        self.queueHandler = queueHandler
        self.queueIdProvider = queueIdProvider
        self.contactsProvider = contactsProvider
    }
    
    func startFetching() {
        timer = Timer.createDispatchTimer(interval: .seconds(timeout),
                                          leeway: .seconds(0),
                                          queue: fetchQueue) { [unowned self] in
            self.fetchTick()
        }
    }
    
    func stopFetching() {
        timer?.cancel()
        timer = nil
    }

}

// MARK: - Privates

extension MessageFetchProvider {
    
    private func fetchTick() {
        do {
            let contacts = contactsProvider.paymentCodeProtocolContacts
            let queueIds = try queueIdProvider.getQueueIds(for: contacts)
            
            guard queueIds.count > 0 else {
                return
            }
            
            self.api.getQueues(queueIds: queueIds) { [unowned self] result in
                switch result {
                case .success(let messageQueues):
                    for messageQueue in messageQueues {
                        self.queueHandler.handleQueue(messageQueue, queue: self.fetchQueue)
                    }
                case .failure(let error):
                    self.fetchFailed(with: error)
                }
            }
            
        } catch let error {
            self.fetchFailed(with: error)
        }
    }
    
    private func fetchFailed(with error: Error) {
        Logger.error("Fetch tick failed with: \(error.localizedDescription)")
    }
    
}

enum MessageFetchProviderError: LocalizedError {
    case noQueueIds
    
    var errorDescription: String? {
        return "You have no contacts"
    }
}
