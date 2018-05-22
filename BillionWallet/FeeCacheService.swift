//
//  FeeCacheService.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct FeeCache: Codable {
    var timestamp: Double
    var fees: [FeeEstimate]
}

protocol FeeCacheStorage {
    func store(_ cache: FeeCache)
    func load() -> FeeCache?
}

struct FeeCacheFileStorage: FeeCacheStorage {
    private let url: URL
    private let datafh: DataFileHandler
    
    init(url: URL, fileHandler: DataFileHandler) {
        self.url = url
        self.datafh = fileHandler
    }
    
    func store(_ cache: FeeCache) {
        do {
            let data = try JSONEncoder().encode(cache)
            try datafh.write(data, to: url)
        } catch let error {
            Logger.error("Failed to store fee cache data: \(error.localizedDescription)")
        }
    }
    
    func load() -> FeeCache? {
        do {
            let data = try datafh.read(from: url)
            let cache = try JSONDecoder().decode(FeeCache.self, from: data)
            return cache
        } catch let error {
            Logger.error("Failed to load stored fee cache data: \(error.localizedDescription)")
            return nil
        }
    }
}

protocol FeeCacheService {
    var timestamp: TimeInterval { get }
    var fees: [FeeEstimate] { get }
    
    func setFees(fees: [FeeEstimate], timestamp: TimeInterval)
}

class StandardFeeCacheService: FeeCacheService {
    private var storage: FeeCacheStorage
    private var cache: FeeCache
    
    init(storage: FeeCacheStorage) {
        self.storage = storage
        if let cache = storage.load() {
            self.cache = cache
        } else {
            self.cache = FeeCache(timestamp: 0, fees: [])
        }
    }
    
    var timestamp: TimeInterval {
        return cache.timestamp as TimeInterval
    }
    
    var fees: [FeeEstimate] {
        return cache.fees
    }
    
    func setFees(fees: [FeeEstimate], timestamp: TimeInterval) {
        cache.timestamp = timestamp
        cache.fees = fees
        storage.store(cache)
    }
}
