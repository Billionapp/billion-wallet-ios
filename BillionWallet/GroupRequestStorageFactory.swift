//
//  GroupRequestStorageFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupRequestStorageFactory {
    
    let requestProvider: UserPaymentRequestProtocol
    
    init(requestProvider: UserPaymentRequestProtocol) {
        self.requestProvider = requestProvider
    }

    func create() -> GroupRequestStorage {
        let fileManager = FileManager.default
        guard let url = fileManager.containerURL(forSecurityApplicationGroupIdentifier: "group.com.evogroup.billionwallet")?.appendingPathComponent("UserRequest") else {
            fatalError("Invalid group id")
        }
        let fileStorage = FileStorage(saveDir: url, fileManager: FileManager.default)
        let storage = GroupRequestStorage(storage: fileStorage, requestProvider: requestProvider)
        return storage
    }
    
}
