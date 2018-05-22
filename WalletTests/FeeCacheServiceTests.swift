//
//  FeeCacheServiceTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 08.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class FeeCacheServiceTests: XCTestCase {
    
    class FakeFeeCacheStorage: FeeCacheStorage {
        var cache: FeeCache? = nil
        
        func store(_ cache: FeeCache) {
            self.cache = cache
        }
        
        func load() -> FeeCache? {
            return cache
        }
    }
    
    class FakeFileHandler: DataFileHandler {
        enum FileHandlerError: Error {
            case notFound
        }
        
        var storage: [URL : Data] = [:]
        
        func write(_ data: Data, to url: URL) throws {
            storage[url] = data
        }
        
        func read(from url: URL) throws -> Data {
            if let data = storage[url] {
                return data
            } else {
                throw FileHandlerError.notFound
            }
        }
    }
    
    var fees: [FeeEstimate] = []
    var timestamp: TimeInterval = 0
    
    override func setUp() {
        super.setUp()
        timestamp = Date().timeIntervalSince1970
        fees = [
            FeeEstimate(avgTime: 10,
                        minDelay: 0,
                        maxDelay: 1,
                        minFee: 10,
                        maxFee: 100)
        ]
    }
    
    func testSaveLoad() {
        let fakeStorage = FakeFeeCacheStorage()
        
        let service = StandardFeeCacheService(storage: fakeStorage)
        service.setFees(fees: fees, timestamp: timestamp)
        
        let otherService = StandardFeeCacheService(storage: fakeStorage)
        XCTAssert(otherService.fees == fees, "Fees don't match \(otherService.fees) != \(fees)")
        XCTAssert(otherService.timestamp == timestamp, "Timestamp don't match \(otherService.timestamp) != \(timestamp)")
    }
    
    func testCacheFileStorage() {
        let dirUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                              in: .userDomainMask).last!
        let url = dirUrl.appendingPathComponent("feecache.json")
        
        let fileHandler = FakeFileHandler()
        
        let storage = FeeCacheFileStorage(url: url, fileHandler: fileHandler)
        
        storage.store(FeeCache(timestamp: timestamp, fees: fees))
        let otherStorage = FeeCacheFileStorage(url: url, fileHandler: fileHandler)
        let cache1 = storage.load()
        let cache2 = otherStorage.load()
    
        if let c1 = cache1 {
            XCTAssert(c1.fees == fees, "Fees don't match for cache1 \(c1.fees) != \(fees)")
            XCTAssert(c1.timestamp == timestamp, "Timestamp doesn't match for cache1 \(c1.timestamp) != \(timestamp)")
        } else {
            XCTFail("Cache1 is nil")
        }
        if let c2 = cache2 {
            XCTAssert(c2.fees == fees, "Fees don't match for cache2 \(c2.fees) != \(fees)")
            XCTAssert(c2.timestamp == timestamp, "Timestamp doesn't match for cache2 \(c2.timestamp) != \(timestamp)")
        } else {
            XCTFail("Cache2 is nil")
        }
    }
}

extension FeeEstimate: Equatable {
    public static func ==(_ lhs: FeeEstimate, _ rhs: FeeEstimate) -> Bool {
        return lhs.avgTime == rhs.avgTime &&
            lhs.maxDelay == rhs.maxDelay &&
            lhs.minDelay == rhs.minDelay &&
            lhs.maxFee == rhs.maxFee &&
            lhs.minFee == rhs.minFee
    }
}
