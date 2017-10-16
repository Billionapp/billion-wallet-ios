//
//  AddNicknameCardVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol  AddNicknameCardVMDelegate: class {
    func contactSaved()
}

class AddNicknameCardVM {
    
    weak var delegate: AddNicknameCardVMDelegate?
    weak var contactsProvider: ContactsProvider?
    
    let contact: UserData
    
    init(contact: UserData, contactsProvider: ContactsProvider?) {
        self.contact = contact
        self.contactsProvider = contactsProvider
    }
    
    var qrImage: UIImage {
        return qrFromString()!
    }
    
    func qrFromString() -> UIImage? {
        return createQRFromString(contact.pc, size: CGSize(width: 280, height: 280), inverseColor: true)
    }
    
    func addContact() {
        
        var friend = FriendContact.create(unique: contact.pc)
        friend.avatarData = contact.avatarData
        friend.displayName = contact.name ?? defaultDisplayName
        friend.nickname = contact.nickName
        
        do {
            try contactsProvider?.save(friend)
            try? ICloud().backup(object: friend)
            delegate?.contactSaved()
        } catch {
            let popup = PopupView(type: .cancel, labelString: "Couldn't save contact")
            UIApplication.shared.keyWindow?.addSubview(popup)
        }
    }
    
}
