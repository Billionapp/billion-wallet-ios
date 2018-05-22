//
//  DefaultsMigrationTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class DefaultsMigrationTests: XCTestCase {
    
    let bundle = Bundle(for: DefaultsMigrationTests.self)
    var defaults: UserDefaults?
    let persistentDomainName = "TestUserDefaults"
    
    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: persistentDomainName)
        
        guard let path = bundle.path(forResource: "defaults-v0.3.5", ofType: "plist") else  {
            XCTFail("defaults-v0.3.5.plist file does not exist")
            return
        }
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any?] else {
            XCTFail("defaults-v0.3.5.plist file could not be read")
            return
        }
        for (key, value) in dict {
            defaults?.set(value, forKey: key)
        }
    }
    
    override func tearDown() {
        defaults?.removePersistentDomain(forName: persistentDomainName)
        super.tearDown()
    }
    
    func testDefaultsMigration() {
        guard let defaults = defaults else {
            XCTFail("Test defaults are nil")
            return
        }
        let migrator = DefaultsMigratorv040(defaults: defaults)
        let migrationAssistant = MigrationAssistant(migrators: [migrator])
        let migrationManager = MigrationManager(defaults: defaults, migrationAssistants: [migrationAssistant])
        migrationManager.migrateAppData(bundleVersionString: "0.4.0", progressDelegate: nil)
        
        guard let path = bundle.path(forResource: "defaults-v0.4.0", ofType: "plist") else  {
            XCTFail("defaults-v0.4.0.plist file does not exist")
            return
        }
        guard let dict = NSDictionary(contentsOfFile: path) as? [String: Any?] else {
            XCTFail("defaults-v0.4.0.plist file could not be read")
            return
        }
        // Check all new keys present in modified plist
        for (key, value) in dict {
            let defValue = defaults.value(forKey: key)
            XCTAssert(defValue != nil, "Value is nil for key \(key)")
            XCTAssert((defValue as? String) == (value as? String), "\(key): \(defValue as? String ?? "nil") != \(value as? String ?? "nil")")
        }
    }
}
