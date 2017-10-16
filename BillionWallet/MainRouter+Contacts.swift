//
//  MainRouter+Contacts.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension MainRouter {

    func showAddContactTypeView() {
        let router = AddContactTypeRouter(mainRouter: self)
        router.run()
    }
    
    func showAddContactNicknameView() {
        let router = AddContactNicknameRouter(mainRouter: self)
        router.run()
    }
    
    func showAddContactAddressView(address: String, txHash: UInt256S?) {
        let router = AddContactAddressRouter(mainRouter: self, address: address, txHash: txHash)
        router.run()
    }
    
    func showNicknameCard(userData: UserData) {
        let router = AddNicknameCardRouter(mainRouter: self, contact: userData, contactsProvider: application.contactsProvider)
        router.run()
    }
    
}
