//
//  GroupFolderProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol GroupFolderProviderProtocol {
    func saveContact(_ contactIndex: ContactIndex, queueId: String) throws
    func getContactIndex(with queueId: String) throws -> ContactIndex
}

class GroupFolderProvider: GroupFolderProviderProtocol {
    
    let storage: FileStorageProtocol
    let coder: ContactIndexCoderProtocol
    
    init(storage: FileStorageProtocol, coder: ContactIndexCoderProtocol) {
        self.storage = storage
        self.coder = coder
    }
    
    func saveContact(_ contactIndex: ContactIndex, queueId: String) throws {
        let data = try coder.encode(contactIndex)
        try? storage.deleteData(by: queueId)
        try storage.write(data, with: queueId)
    }
    
    func getContactIndex(with queueId: String) throws -> ContactIndex {
        let data = try storage.read(by: queueId)
        let contactIndex = try coder.decode(data)
        return contactIndex
    }
    
}
