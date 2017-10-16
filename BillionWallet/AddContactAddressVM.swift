//
//  AddContactAddressVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AddContactAddressVMDelegate: class {
    func contactAdded()
}

class AddContactAddressVM {
    
    weak var delegate: AddContactAddressVMDelegate?
    let contactsProvider: ContactsProvider
    var newContactName: String?
    var newContactAddress: String?
    var newContactTxHash: UInt256S?
    var photo: Data?
    
    init(contactsProvider: ContactsProvider, icloudProvider: ICloud, address: String, txHash: UInt256S?) {
        self.contactsProvider = contactsProvider
        self.newContactAddress = address
        self.newContactTxHash = txHash
    }
    
    func createContact() throws {
        if let address = newContactAddress, let name = newContactName {
            
            if (try? PaymentCode(with: address)) != nil {
                var contact = PaymentCodeContact.create(unique: address)
                contact.avatarData = photo
                contact.displayName = name
                if let txHash = newContactTxHash {
                    contact.txHashes.insert(txHash.data.hex)
                }
                try? ICloud().backup(object: contact)
                try contactsProvider.save(contact)
            } else {
                var contact = AddressContact.create(unique: address)
                contact.avatarData = photo
                contact.displayName = name
                if let txHash = newContactTxHash {
                    contact.txHashes.insert(txHash.data.hex)
                }
                try? ICloud().backup(object: contact)
                try contactsProvider.save(contact)
            }
            delegate?.contactAdded()
            //clear()
        }
    }
}

//MARK: - Private Methods
extension AddContactAddressVM {
    
    fileprivate func clear() {
        newContactAddress = nil
        newContactName = nil
    }
}
