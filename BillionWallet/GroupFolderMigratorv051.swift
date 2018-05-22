//
//  GroupFolderMigratorv051.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupFolderMigratorv051: VersionMigrator {
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.5.1"
    
    let queueIdProvider: QueueIdProviderProtocol
    let contactsProvider: ContactsProvider
    let groupProvider: GroupFolderProviderProtocol
    
    init(queueIdProvider: QueueIdProviderProtocol, contactsProvider: ContactsProvider, groupProvider: GroupFolderProviderProtocol) {
        self.queueIdProvider = queueIdProvider
        self.contactsProvider = contactsProvider
        self.groupProvider = groupProvider
    }
    
    func migrateData() {
        for contact in contactsProvider.allContacts() {
            if let queueId = try? queueIdProvider.getQueueId(for: contact.uniqueValue) {
                let contactIndex = ContactIndex(pc: contact.uniqueValue,
                                                avatarData: contact.avatarData,
                                                queueId: queueId,
                                                name: contact.displayName,
                                                fileNames: [])
                try? groupProvider.saveContact(contactIndex, queueId: queueId)
            }
        }
    }
    
}
