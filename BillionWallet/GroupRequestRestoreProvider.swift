//
//  GroupRequestRestoreProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupRequestRestoreProvider {
    
    let storage: GroupRequestStorage
    let messageStorageManager: MessageStorageManagerProtocol
    let requestProvider: UserPaymentRequestProtocol
    let messageWrapper: MessageWrapperProtocol
    
    init(storage: GroupRequestStorage, messageStorageManager: MessageStorageManagerProtocol, requestProvider: UserPaymentRequestProtocol, messageWrapper: MessageWrapperProtocol) {
        self.storage = storage
        self.messageStorageManager = messageStorageManager
        self.requestProvider = requestProvider
        self.messageWrapper = messageWrapper
    }
    
    func restoreFromBackup() {
        DispatchQueue.global().async { [unowned self] in
            do {
                let messages = try self.storage.restoreMessages()
                for data in messages {
                    guard let mesageType = try? self.messageWrapper.unwrap(data) else {
                        continue
                    }
                    
                    // TODO: Add payment code here
                    try self.messageStorageManager.store(type: mesageType.type, json: mesageType.json, paymentCode: "")
                }
                try self.storage.clearDirectory()
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }
    
}
