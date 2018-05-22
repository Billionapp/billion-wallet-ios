//
//  OnboardVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol OnboardVMDelegate: class {
    func didFinishOnboarding()
}

class OnboardVM {
    weak var delegate: OnboardVMDelegate?
    weak var defaultsProvider: Defaults!
    weak var failureTxProvider: FailureTxProtocol!
    weak var userPaymentRequestProvider: UserPaymentRequestProtocol!
    weak var selfPaymentRequestProvider: SelfPaymentRequestProtocol!
    weak var accountProvider: AccountManager!
    weak var contactsProvider: ContactsProvider!
    
    init(defaultsProvider: Defaults,
         accountProvider: AccountManager,
         contactsProvider: ContactsProvider,
         failureTxProvider: FailureTxProtocol,
         userPaymentRequestProvider: UserPaymentRequestProtocol,
         selfPaymentRequestProvider: SelfPaymentRequestProtocol) {
        
        self.defaultsProvider = defaultsProvider
        self.accountProvider = accountProvider
        self.contactsProvider = contactsProvider
        self.failureTxProvider = failureTxProvider
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
    }
    
    func flushOldDataIfRestored() {
        DispatchQueue.global().async {
            self.contactsProvider.deleteAllContacts()
            self.failureTxProvider.deleteAllFailureTxs {}
            self.userPaymentRequestProvider.deleteAllUserPaymentRequest {}
            self.selfPaymentRequestProvider.deleteAllSelfPaymentRequest {}
            self.accountProvider.clearAccountKeychain()
        }
    }
}

