//
//  PaymentRequestMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PaymentRequestMigrationAssistantFactory: MigrationAssistantFactory {
    
    let selfPRstorage: SelfPaymentRequestStorageProtocol
    let userPRstorage: UserPaymentRequestStorageProtocol
    
    init(selfPRstorage: SelfPaymentRequestStorageProtocol, userPRstorage: UserPaymentRequestStorageProtocol) {
        self.selfPRstorage = selfPRstorage
        self.userPRstorage = userPRstorage
    }
    
    func createAssistant() -> MigrationAssistantProtocol {
        let versionMigrators: [VersionMigrator] = [
            PaymentRequestMigratorv051(selfPRstorage: selfPRstorage, userPRstorage: userPRstorage)
        ]
        
        let assistant = MigrationAssistant(migrators: versionMigrators)
        return assistant
    }
}
