//
//  RateHistoryStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class RateHistoryStorage: RateHistoryStorageProtocol {
    
    private lazy var objId: String = {
        let id = "\(type(of: self)):\(String(format: "%p", unsafeBitCast(self, to: Int.self)))"
        return id
    }()
    
    private var _maxTimestamp: Int64?
    private var _existingTimestamps: Set<Int64>?
    private let lock: NSLock
    let storage: FileStorageProtocol
    let serializer: RateSerializerProtocol
    var channel: Channel<StorageMessage>?
    
    init(storage: FileStorageProtocol, serializer: RateSerializerProtocol) {
        self.storage = storage
        self.serializer = serializer
        self.lock = NSLock()
        self._existingTimestamps = nil
        self._maxTimestamp = nil
    }
    
    deinit {
        self.channel?.removeObserver(withId: self.objId)
        self.channel = nil
    }
    
    func setChannel(_ channel: Channel<StorageMessage>) {
        self.channel = channel
        let observer = Observer<StorageMessage>(id: objId, callback: { [weak self] message in
            self?.acceptStorageMessage(message)
        })
        self.channel?.addObserver(observer)
    }
    
    func acceptStorageMessage(_ message: StorageMessage) {
        lock.lock()
        defer { lock.unlock() }
        
        switch message {
        case .add(let filename):
            if let timestamp = Int64(filename) {
                self._existingTimestamps?.insert(timestamp)
                if (self._maxTimestamp ?? 0) < timestamp {
                    self._maxTimestamp = timestamp
                }
            }
        case .remove(let filename):
            if let timestamp = Int64(filename) {
                self._existingTimestamps?.remove(timestamp)
                if (self._maxTimestamp ?? 0) == timestamp {
                    self._maxTimestamp = _existingTimestamps?.max()
                }
            }
        case .updateAll:
            do {
                try self.updateTimestamps()
            } catch let error {
                Logger.warn("\(error.localizedDescription)")
            }
        }
    }
    
    @discardableResult
    private func updateTimestamps() throws -> Set<Int64> {
        self._existingTimestamps = Set(try storage.listOfFiles().flatMap { Int64($0) })
        self._maxTimestamp = _existingTimestamps!.max()
        return self._existingTimestamps!
    }
    
    func getRateHistory(forTimestamp timestamp: Int64) throws -> RateHistory {
        let fileName = "\(timestamp)"
        let data = try storage.read(by: fileName)
        let rateHistory = try serializer.deserializeFromData(data)
        return rateHistory
    }
    
    func update(with rateHistory: RateHistory) throws {
        let data = try self.serializer.serializeToData(rateHistory)
        let fileName = "\(rateHistory.blockTimestamp)"
        try self.storage.write(data, with: fileName)
    }
    
    func delete(forTimestamp timestamp: Int64) throws {
        let fileName = "\(timestamp)"
        try storage.deleteData(by: fileName)
    }
    
    func getMaxTimestamp() throws -> Int64? {
        lock.lock()
        defer { lock.unlock() }
        
        if let max = _maxTimestamp {
            return max
        } else {
            try self.updateTimestamps()
            return _maxTimestamp
        }
    }
    
    func existingTimestamps() throws -> Set<Int64> {
        lock.lock()
        defer { lock.unlock() }
        
        if let timestamps = _existingTimestamps {
            return timestamps
        } else {
            return try self.updateTimestamps()
        }
    }
}
