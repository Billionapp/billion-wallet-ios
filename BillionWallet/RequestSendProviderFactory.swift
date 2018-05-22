//
//  RequestSendProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RequestSendProviderFactory {
    
    let api: API
    let accountManager: AccountManager
    let contactsProvider: ContactsProvider
    let userPaymentRequestProvider: UserPaymentRequestProtocol
    let selfPaymentRequestProvider: SelfPaymentRequestProtocol
    
    init(api: API, accountManager: AccountManager, contactsProvider: ContactsProvider, userPaymentRequestProvider: UserPaymentRequestProtocol, selfPaymentRequestProvider: SelfPaymentRequestProtocol) {
        self.api = api
        self.accountManager = accountManager
        self.contactsProvider = contactsProvider
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
    }
    
    func create() -> RequestSendProviderProtocol {
        let queueIdProvide = QueueIdSendProvider(accountManager: accountManager, contactsProvider: contactsProvider)
        let messageSender = MessageSender(api: api, queueIdSendProvider: queueIdProvide, accountManager: accountManager)
        let wrapper = MessageWrapper()
        return RequestSendProvider(api: api, paymentRequestProvider: userPaymentRequestProvider, selfRequestProvider: selfPaymentRequestProvider, accountManager: accountManager, messageSender: messageSender, wrapper: wrapper)
    }

}
