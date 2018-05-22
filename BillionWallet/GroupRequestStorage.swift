//
//  GroupRequestStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupRequestStorage {

    let storage: FileStorage
    let requestProvider: UserPaymentRequestProtocol
    
    init(storage: FileStorage, requestProvider: UserPaymentRequestProtocol) {
        self.storage = storage
        self.requestProvider = requestProvider
    }
    
    func store(_ data: Data, fileName: String) throws {
        try storage.write(data, with: fileName)
    }
    
    func restoreMessages() throws -> [Data] {
        let list = try Array(storage.listOfFiles())
        var messages = [Data]()
        for item in list {
            let data = try storage.read(by: item)
            messages.append(data)
        }
        return messages
    }
    
    func clearDirectory() throws {
        let list = try Array(storage.listOfFiles())
        for item in list {
            try storage.deleteData(by: item)
        }
    }
    
}
