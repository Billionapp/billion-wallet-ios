//
//  GroupFolderMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by Artur Guseinov on 24/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GroupFolderMigrationAssistantFactory: MigrationAssistantFactory {
    
    let queueIdProvider: QueueIdProviderProtocol
    let contactsProvider: ContactsProvider
    let groupProvider: GroupFolderProviderProtocol
    
    init(queueIdProvider: QueueIdProviderProtocol, contactsProvider: ContactsProvider, groupProvider: GroupFolderProviderProtocol) {
        self.queueIdProvider = queueIdProvider
        self.contactsProvider = contactsProvider
        self.groupProvider = groupProvider
    }
    
    func createAssistant() -> MigrationAssistantProtocol {
        let versionMigrators: [VersionMigrator] = [
            GroupFolderMigratorv051(queueIdProvider: queueIdProvider,
                                    contactsProvider: contactsProvider,
                                    groupProvider: groupProvider)
        ]
        
        let assistant = MigrationAssistant(migrators: versionMigrators)
        return assistant
    }

}
