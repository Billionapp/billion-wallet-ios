//
//  AddContactVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AddContactVMDelegate: class {
    func didReceive(_ contact: ContactProtocol)
    func didFailed(with error: Error)
    func addContactProviderReadyForSearch()
    func didRecognize(billionCode: String)
}

class AddContactVM {

    weak var delegate: AddContactVMDelegate?
    weak var addContactProvider: AddContactProvider!
    weak var contactsProvider: ContactsProvider!
    var qrResolver: QrResolver?

    init(addContactProvider: AddContactProvider, contactsProvider: ContactsProvider) {
        self.addContactProvider = addContactProvider
        self.contactsProvider = contactsProvider
        self.addContactProvider.delegate = self
    }

    deinit {
        addContactProvider.stop()
    }
    
    lazy var pcHandler: QrResolver.Callback  = { [weak self] (pc) in
        self?.findPaymentCode(str: pc)
    }
    
    func findPaymentCode(str: String) {
        delegate?.didRecognize(billionCode: str)
    }
    
    func setResolver(_ resolver: QrResolver) {
        self.qrResolver = resolver
    }
}

// MARK: - AddContactProviderDelegate

extension AddContactVM: AddContactProviderDelegate {
    
    func addContactProviderFailed(with error: Error) {
        addContactProvider.stop()
        delegate?.didFailed(with: error)
    }
    
    func addContactProviderReceive(_ contact: ContactProtocol) {
        if let contact: FriendContact = contactsProvider.getContact(uniqueValue: contact.uniqueValue), contact.isArchived == false {
            return
        }
        
        delegate?.didReceive(contact)
    }
    
    func addContactProviderReadyForSearch() {
        delegate?.addContactProviderReadyForSearch()
    }
    
}
