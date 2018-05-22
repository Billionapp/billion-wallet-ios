//
//  ContactCardVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol ContactCardVMDelegate: class {
    func didReceiveSharePicture(_ sharePic: UIImage)
    func didReceiveContact(_ contact: ContactProtocol)
    func didDelete()
    func startLoader()
    func stopLoader()
}

class ContactCardVM {
    private let urlComposer: URIComposer
    private let contactProvider: ContactsProvider
    private var contact: ContactProtocol
    private var apiProvider: API!
    
    weak var delegate: ContactCardVMDelegate?
    
    init(contactProvider: ContactsProvider,
         contact: ContactProtocol,
         urlComposer: URIComposer,
         apiProvider: API) {
        
        self.contactProvider = contactProvider
        self.urlComposer = urlComposer
        self.contact = contact
        self.apiProvider = apiProvider
    }
    
    var displayName: String {
        return contact.displayName
    }
    
    var urlToShare: String {
        return urlComposer.getContactURI(with: contact.uniqueValue, contactName: contact.displayName)
    }
    
    func getContact() {
        delegate?.didReceiveContact(contact)
    }
    
    func shareContact(card: UIImage) {        
        delegate?.didReceiveSharePicture(card)
    }
    
    func didChangePhoto(photo: UIImage) {
        contact.avatarData = photo.tuneCompress()
        save()
    }
    
    func didChangeName(name: String) {
        contact.givenName = name
    }
    
    func refreshContact() {
        delegate?.startLoader()
        apiProvider.findUser(pc: contact.uniqueValue) { (result) in
            switch result {
            case .success(let user):
                if let name = user.name {
                    self.contact.displayName = name
                }
                self.contact.avatarData = user.avatarData
                self.contactProvider.save(self.contact)
                DispatchQueue.main.async {
                    self.delegate?.didReceiveContact(self.contact)
                    self.delegate?.stopLoader()
                }
            case .failure(let error):
                Logger.debug("\(error.localizedDescription)")
                self.delegate?.stopLoader()
            }
        }
    }
    
    func save() {
        contactProvider.save(contact)
        let clearCacheForContact = "ClearCacheForContactNotification"
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: clearCacheForContact), object: nil, userInfo: ["cacheString": contact.displayName])
    }
    
    func archiveContact() {
        DispatchQueue.global().async {
            self.contact.isArchived = true
            self.contactProvider.save(self.contact)
        }
        delegate?.didDelete()
    }

}
