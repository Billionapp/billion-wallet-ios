//
//  ContactsTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class ContactsTests: XCTestCase {
    
    let contactsProvider = ContactsProvider()
    
    let _address = "bdf6b281b84af422a5977baee798678e4f1d6aa7"
    let _paymentCode = "PM8TJdjVPTRnxV5n4M2YuCzcUnVtzJuECTgFX2A3PF8q8F7pmYQTJ8MCXgTrJ16SshgSwFay2n1DjZ3XUsQh9VRLs3gs7PKvZQEPPG54XRyvozPK4hge"
    let _nickname = "nickname"
    let _displayName = "displayName"
    let _isArchived = true
    
    override func setUp() {
        super.setUp()
        
        contactsProvider.deleteAllContacts()
    }
    
    override func tearDown() {
        
        contactsProvider.deleteAllContacts()
        super.tearDown()
    }
    
    func testAddressContactCreation() {
        let addressContact = AddressContact.create(unique: _address)
        addressContact.save()
        
        var findedAddressContact: AddressContact = contactsProvider.getOrCreateAddressContact(address: _address)
        XCTAssertEqual(findedAddressContact.address, addressContact.address)
        
        // change all ununique variables
        findedAddressContact.displayName = _displayName + "123"
        findedAddressContact.avatarData = Data()
        findedAddressContact.isArchived = !findedAddressContact.isArchived
        findedAddressContact.save()
        
        let findedUpdatedAddressContact: AddressContact = contactsProvider.getOrCreateAddressContact(address: _address)
        
        XCTAssertEqual(addressContact.address, findedUpdatedAddressContact.address)
        XCTAssertNotEqual(addressContact.displayName, findedUpdatedAddressContact.displayName)
        XCTAssertNotEqual(addressContact.avatarData, findedUpdatedAddressContact.avatarData)
        XCTAssertNotEqual(addressContact.isArchived, findedUpdatedAddressContact.isArchived)
        XCTAssertEqual(contactsProvider.addessContacts.count == 1, true)
    }
    
    func testPaymentCodeContactCreation() {
        var paymentCodeContact = PaymentCodeContact.create(unique: _paymentCode)
        paymentCodeContact.displayName = _displayName
        paymentCodeContact.avatarData = nil
        paymentCodeContact.isArchived = _isArchived
        paymentCodeContact.save()
        
        let findedPaymentCodeContact: PaymentCodeContact = contactsProvider.getOrCreatePaymentCodeContact(paymentCode: _paymentCode)
        XCTAssertEqual(findedPaymentCodeContact.paymentCode, paymentCodeContact.paymentCode)
        XCTAssertEqual(findedPaymentCodeContact.receiveAddresses.count == 100, true)
        
        // change all ununique variables
        var updatedAddressContact = PaymentCodeContact.create(unique: _paymentCode)
        updatedAddressContact.displayName = _displayName + "123"
        updatedAddressContact.avatarData = Data()
        updatedAddressContact.isArchived = !_isArchived
        updatedAddressContact.save()
        
        let findedUpdatedPaymentCodeContact = contactsProvider.getOrCreatePaymentCodeContact(paymentCode: _paymentCode)
        
        XCTAssertEqual(findedPaymentCodeContact.paymentCode, findedUpdatedPaymentCodeContact.paymentCode)
        XCTAssertNotEqual(findedPaymentCodeContact.displayName, findedUpdatedPaymentCodeContact.displayName)
        XCTAssertNotEqual(findedPaymentCodeContact.avatarData, findedUpdatedPaymentCodeContact.avatarData)
        XCTAssertNotEqual(findedPaymentCodeContact.isArchived, findedUpdatedPaymentCodeContact.isArchived)
        XCTAssertEqual(findedPaymentCodeContact.receiveAddresses.count, findedUpdatedPaymentCodeContact.receiveAddresses.count)
        XCTAssertEqual(contactsProvider.paymentCodeContacts.count == 1, true)
    }
    
    func testFriendContactCreation() {
        var friendContact = FriendContact.create(unique: _paymentCode)
        friendContact.nickname = _nickname
        friendContact.displayName = _displayName
        friendContact.avatarData = nil
        friendContact.isArchived = _isArchived
        friendContact.save()

        var isNew: Bool?
        let findedFriendContact: FriendContact = contactsProvider.getContactOrCreate(uniqueValue: _paymentCode, isNew: &isNew)
        XCTAssertEqual(findedFriendContact.paymentCode, friendContact.paymentCode)
        XCTAssertEqual(findedFriendContact.receiveAddresses.count == 100, true)

        // change all ununique variables
        var updatedNicknameContact = FriendContact.create(unique: _paymentCode)
        updatedNicknameContact.nickname = _nickname + "123"
        updatedNicknameContact.displayName = _displayName + "123"
        updatedNicknameContact.avatarData = Data()
        updatedNicknameContact.isArchived = !_isArchived
        updatedNicknameContact.save()

        let findedUpdatedFriendContact: FriendContact = contactsProvider.getContactOrCreate(uniqueValue: _paymentCode, isNew: &isNew)

        XCTAssertEqual(findedFriendContact.paymentCode, findedUpdatedFriendContact.paymentCode)
        XCTAssertNotEqual(findedFriendContact.displayName, findedUpdatedFriendContact.displayName)
        XCTAssertNotEqual(findedFriendContact.avatarData, findedUpdatedFriendContact.avatarData)
        XCTAssertNotEqual(findedFriendContact.isArchived, findedUpdatedFriendContact.isArchived)
        XCTAssertEqual(contactsProvider.friends.count == 1, true)
    }
    
}
