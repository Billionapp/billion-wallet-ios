//
//  PushConfigurator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PushConfigurator {
    private let api: API
    private let defaults: Defaults
    private let queueIdProvider: QueueIdProviderProtocol
    private let contactsProvider: ContactsProvider
    private var contactChannel: ContactChannel?
    private let observerId: Identifier
    
    init(api: API, defaults: Defaults, queueIdProvider: QueueIdProviderProtocol, contactsProvider: ContactsProvider) {
        self.api = api
        self.defaults = defaults
        self.queueIdProvider = queueIdProvider
        self.contactsProvider = contactsProvider
        self.contactChannel = nil
        self.observerId = Identifier("\(type(of: self))")
    }
    
    deinit {
        contactChannel?.removeObserver(withId: observerId)
    }
    
    func configurePush(token: Data, completion: @escaping (Result<String>) -> Void) {
        #if DEBUG
        let env = "dev"
        #else
        let env = "prod"
        #endif
        #if BITCOIN_TESTNET
        let net = "test"
        #else
        let net = "main"
        #endif
        Logger.debug(token.hex)
        if let savedToken = defaults.apnsToken,
            savedToken == token {
            Logger.debug("Token did not change since last time")
//            return
        }
        api.configPush(env: env, token: token.hex, net: net) { (result: Result<String>) in
            switch result {
            case .success:
                Logger.debug("Push configuration succeeded")
                self.configureMessenger(completion: completion)
            case .failure(let error):
                Logger.error(error.localizedDescription)
                completion(.failure(error))
            }
        }
    }
    
    func setContactChannel(_ channel: ContactChannel) {
        self.contactChannel = channel
        channel.addObserver(Observer<ContactsProvider.ContactMessage>(id: observerId, callback: { [weak self] message in
            self?.acceptContactMessage(message)
        }))
    }
    
    private lazy var acceptContactMessage: (ContactsProvider.ContactMessage) -> Void = { [weak self] message in
        guard let strongSelf = self else { return }
        
        switch message {
        case .contactUpdated:
            strongSelf.configureMessenger(completion: nil)
        default:
            break
        }
    }
    
    func configureMessenger(completion: ((Result<String>) -> Void)?) {
        DispatchQueue.global().async { [unowned self] in
            do {
                let contacts = self.contactsProvider.paymentCodeProtocolContacts
                let queueIds = try self.queueIdProvider.getQueueIds(for: contacts)
                
                guard queueIds.count > 0 else {
                    completion?(.success("Success"))
                    return
                }
                
                self.api.subscribe(queueIds: queueIds) { (result: Result<String>) in
                    switch result {
                    case .success:
                        Logger.debug("Push configuration succeeded")
                        completion?(.success("Success"))
                    case .failure(let error):
                        Logger.error(error.localizedDescription)
                        completion?(.failure(error))
                    }
                }
            }
            catch {
                Logger.error(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
        
        
}
