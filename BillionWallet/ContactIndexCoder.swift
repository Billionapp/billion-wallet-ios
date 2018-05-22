//
//  ContactIndexCoder.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol ContactIndexCoderProtocol {
    func decode(_ data: Data) throws -> ContactIndex
    func encode(_ contact: ContactIndex) throws -> Data
}

class ContactIndexCoder: ContactIndexCoderProtocol {
    
    func decode(_ data: Data) throws -> ContactIndex {
        let contact = try JSONDecoder().decode(ContactIndex.self, from: data)
        return contact
    }
    
    func encode(_ contact: ContactIndex) throws -> Data {
        let data = try JSONEncoder().encode(contact)
        return data
    }
    
}
