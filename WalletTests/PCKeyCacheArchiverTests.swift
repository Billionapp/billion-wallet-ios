//
//  PCKeyCacheArchiverTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 14.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class PCKeyCacheArchiverTests: XCTestCase {
    
    let _keBytes: [UInt8] = "176c720a129a44817a3038a9fa5f51bf487c0a56ec0a5c4a437bb2909d50540b".unHexed
    let _kmBytes: [UInt8] = "006166061dc82ec2d4a275615ef59804f68147fd4728a94052f015dec3ae9c7b".unHexed
    
    var provider: ECIESConfigFactory!
    var archiver1: PCKeyCacheBase64Archiver!
    var archiver2: PCKeyCacheBase64Archiver!
    
    override func setUp() {
        super.setUp()
        provider = ECIESConfigFactory()
        archiver1 = PCKeyCacheBase64Archiver(factory: provider)
        archiver2 = PCKeyCacheBase64Archiver(factory: provider)
    }
    
    func testArchiveUnarchive() {
        let ke = Data(_keBytes)
        let km = Data(_kmBytes)
        let config = provider.genECIESConfig(identifier: .cryptoSwift)
        let keyCache = PCKeyCache(Ke: ke, Km: km, config: config)
        
        let archiveData1 = archiver1.archive(keyCache)
        XCTAssert(archiveData1.count > 0, "Archived data 1 is empty")
        
        let archiveData2 = archiver2.archive(keyCache)
        XCTAssert(archiveData2.count > 0, "Archived data 2 is empty")
        XCTAssert(archiveData1 == archiveData2, "Archived data 1 and 2 don't match \(archiveData1) != \(archiveData2)")
        
        var recoveredKeyCache1: PCKeyCache! = nil
        var recoveredKeyCache2: PCKeyCache! = nil
        do {
            recoveredKeyCache1 = try archiver2.unarchive(archiveData1)
            recoveredKeyCache2 = try archiver1.unarchive(archiveData2)
        } catch let error {
            XCTFail("Error unarchiving data: \(error.localizedDescription)")
            return
        }
        XCTAssert(recoveredKeyCache1.Ke == keyCache.Ke, "\(recoveredKeyCache1.Ke) != \(keyCache.Ke)")
        XCTAssert(recoveredKeyCache1.Km == keyCache.Km, "\(recoveredKeyCache1.Km) != \(keyCache.Km)")
        XCTAssert(recoveredKeyCache2.Ke == keyCache.Ke, "\(recoveredKeyCache2.Ke) != \(keyCache.Ke)")
        XCTAssert(recoveredKeyCache2.Km == keyCache.Km, "\(recoveredKeyCache2.Km) != \(keyCache.Km)")
        XCTAssert(recoveredKeyCache1.config.S1 == keyCache.config.S1, "\(recoveredKeyCache1.config.S1) != \(keyCache.config.S1)")
        XCTAssert(recoveredKeyCache2.config.S1 == keyCache.config.S1, "\(recoveredKeyCache2.config.S1) != \(keyCache.config.S1)")
        XCTAssert(recoveredKeyCache1.config.S2 == keyCache.config.S2, "\(recoveredKeyCache1.config.S2) != \(keyCache.config.S2)")
        XCTAssert(recoveredKeyCache2.config.S2 == keyCache.config.S2, "\(recoveredKeyCache2.config.S2) != \(keyCache.config.S2)")
        XCTAssert(recoveredKeyCache1.config.identifier == keyCache.config.identifier, "\(recoveredKeyCache1.config.identifier) != \(keyCache.config.identifier)")
        XCTAssert(recoveredKeyCache2.config.identifier == keyCache.config.identifier, "\(recoveredKeyCache2.config.identifier) != \(keyCache.config.identifier)")
    }
}
