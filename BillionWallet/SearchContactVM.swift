//
//  SearchContactVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol SearchContactVMDelegate: class {
    func userDidFound(user: ContactProtocol)
    func userNotFound(errorMessage: String)
}

class SearchContactVM {
    
    typealias LocalizedString = Strings.SearchContact
    weak var delegate: SearchContactVMDelegate?
    weak var apiProvider: API!
    private let contactsProvider: ContactsProvider
    let billionCode: String
    
    init(billionCode: String, apiProvider: API, contactsProvider: ContactsProvider) {
        self.billionCode = billionCode
        self.apiProvider = apiProvider
        self.contactsProvider = contactsProvider
    }
    
    func getUser() {
        apiProvider.findUser(pc: billionCode) { (result) in
            switch result {
            case .success(let user):
                var contact = FriendContact.create(unique: user.pc)
                if let name = user.name {
                   contact.displayName = name
                }
                contact.avatarData = user.avatarData
                DispatchQueue.main.async {
                    self.delegate?.userDidFound(user: contact)
                }
            case .failure:
                var contact = self.contactsProvider.getOrCreatePaymentCodeContact(paymentCode: self.billionCode)
                contact.isArchived = false
                self.contactsProvider.save(contact)
                DispatchQueue.main.async {
                    self.delegate?.userDidFound(user: contact)
                }
            }
        }
    }
}

//MARK: - Private methods
extension SearchContactVM {
    fileprivate func generateFailureMessage(from error: Error) -> String {
        let message: String
        if let customError = error as? NetworkError {
            switch customError {
            case .statusFailed:
                 message = LocalizedString.contactNotFoud
            default :
                message = LocalizedString.searchFailed
            }
        } else {
            message = LocalizedString.searchFailed
        }
        
        return message
    }
}
