//
//  RateCachedStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RateCachedStorage: RateHistoryStorageProtocol {
    private var cache: [Int64: RateHistory]
    private var storage: RateHistoryStorageProtocol
    
    init(storage: RateHistoryStorageProtocol) {
        self.storage = storage
        self.cache = [:]
    }
    
    func getRateHistory(forTimestamp timestamp: Int64) throws -> RateHistory {
        if let rateHistory = cache[timestamp] {
            return rateHistory
        }
        let rateHistory = try storage.getRateHistory(forTimestamp: timestamp)
        cache[rateHistory.blockTimestamp] = rateHistory
        return rateHistory
    }
    
    func update(with rateHistory: RateHistory) throws {
        try storage.update(with: rateHistory)
        cache[rateHistory.blockTimestamp] = rateHistory
    }
    
    func delete(forTimestamp timestamp: Int64) throws {
        try storage.delete(forTimestamp: timestamp)
        cache.removeValue(forKey: timestamp)
    }
    
    func getMaxTimestamp() throws -> Int64? {
        return try storage.getMaxTimestamp()
    }
    
    func existingTimestamps() throws -> Set<Int64> {
        return try storage.existingTimestamps()
    }
}
