//
//  PinCodeMigrationAssistantFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class PinCodeMigrationAssistantFactory: MigrationAssistantFactory {
    
    private let app: Application
    private let keychain: Keychain
    
    init(app: Application, keychain: Keychain) {
        self.app = app
        self.keychain = keychain
    }
    
    func createAssistant() -> MigrationAssistantProtocol {
        
        let passcodeRouter = PasscodeRouter(mainRouter: app.mainRouter, passcodeCase: .migrate(pinSize: 6), output: nil, app: app, reason: nil)
        
        let versionMigrators: [VersionMigrator] = [
            PinCodeMigratorv040(keychain: keychain, passcodeRouter: passcodeRouter)
        ]
        
        let assistant = MigrationAssistant(migrators: versionMigrators)
        return assistant
    }
}
