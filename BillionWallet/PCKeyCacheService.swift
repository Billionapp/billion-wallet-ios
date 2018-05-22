//
//  PCKeyCacheService.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol PCKeyCacheService {
    func getKey(selfPC: Data, otherPC: Data, selfIndex: UInt32, otherIndex: UInt32) -> String
    func storeCache(_ cache: PCKeyCache, forKey key: String)
    func getCache(forKey key: String) -> PCKeyCache?
}

class ChatKeysCache: PCKeyCacheService {
    private let archiver: PCKeyCacheArchiver
    private let secureStorage: SecureDataStorage
    
    init(archiver: PCKeyCacheArchiver, secureStorage: SecureDataStorage) {
        self.archiver = archiver
        self.secureStorage = secureStorage
    }
    
    func getKey(selfPC: Data, otherPC: Data, selfIndex: UInt32, otherIndex: UInt32) -> String {
        var data = Data()
        data.append(selfPC)
        data.append(otherPC)
        data.append(selfIndex)
        data.append(otherIndex)
        return data.base64EncodedString()
    }
    
    func storeCache(_ cache: PCKeyCache, forKey key: String) {
        let archive = archiver.archive(cache)
        secureStorage.store(archive, forKey: key)
    }
    
    func getCache(forKey key: String) -> PCKeyCache? {
        guard let archivedData = secureStorage.load(key: key) else {
            return nil
        }
        do {
            let cache = try archiver.unarchive(archivedData)
            return cache
        } catch let error {
            Logger.error("Unarchive failed with error: \(error.localizedDescription)")
            return nil
        }
    }
}
