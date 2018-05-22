//
//  MessageFetchProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MessageFetchProviderFactory {
    
    let api: API
    let accountManager: AccountManager
    let contactsProvider: ContactsProvider
    let userPaymentRequestProvider: UserPaymentRequestProtocol
    let selfPaymentRequestProvider: SelfPaymentRequestProtocol
    
    init(api: API,
         accountManager: AccountManager,
         contactsProvider: ContactsProvider,
         userPaymentRequestProvider: UserPaymentRequestProtocol,
         selfPaymentRequestProvider: SelfPaymentRequestProtocol) {
        self.api = api
        self.accountManager = accountManager
        self.contactsProvider = contactsProvider
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
    }
    
    func createFetcher() -> MessageFetchProviderProtocol {
        let queueIdProvider = QueueIdReceiveProvider(accountManager: accountManager)
        let storage = MessageStorageManager(userPaymentRequestProvider: userPaymentRequestProvider, selfPaymentRequestProvider: selfPaymentRequestProvider)
        let wrapper = MessageWrapper()
        let queueHandler = QueueHandler(api: api, queueIdProvider: queueIdProvider, storage: storage, wrapper: wrapper, contactsProvider: contactsProvider, accountManager: accountManager)
        return MessageFetchProvider(api: api, queueHandler: queueHandler, queueIdProvider: queueIdProvider, contactsProvider: contactsProvider)
    }

}
