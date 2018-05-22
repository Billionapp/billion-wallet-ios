//
//  PCKeyCacheArchiver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum PCKeyCacheArchiverError: LocalizedError {
    case dataParsingError
    case unknownIdentifier
    
    var errorDescription: String? {
        switch self {
        case .dataParsingError:
            return "Archive parsing error."
        case .unknownIdentifier:
            return "Unknown ECIES config identifier."
        }
    }
}

protocol PCKeyCacheArchiver {
    func archive(_ cache: PCKeyCache) -> Data
    func unarchive(_ archive: Data) throws -> PCKeyCache
}

class PCKeyCacheBase64Archiver: PCKeyCacheArchiver {
    enum Keys {
        static let Ke = "ke"
        static let Km = "km"
        static let S1 = "s1"
        static let S2 = "s2"
        static let identifier = "id"
    }
    
    private let factory: ECIESConfigProvider
    
    init(factory: ECIESConfigProvider) {
        self.factory = factory
    }
    
    func archive(_ cache: PCKeyCache) -> Data {
        let cacheDict: [String: String] = [
            Keys.Ke: cache.Ke.base64EncodedString(),
            Keys.Km: cache.Km.base64EncodedString(),
            Keys.S1: cache.config.S1.base64EncodedString(),
            Keys.S2: cache.config.S2.base64EncodedString(),
            Keys.identifier: cache.config.identifier.rawValue
        ]
        let archive = try! JSONEncoder().encode(cacheDict)
        return archive
    }
    
    func unarchive(_ archive: Data) throws -> PCKeyCache {
        let cacheDict = try JSONDecoder().decode([String: String].self, from: archive)
        guard let ke_base64 = cacheDict[Keys.Ke],
            let km_base64 = cacheDict[Keys.Km],
            let s1_base64 = cacheDict[Keys.S1],
            let s2_base64 = cacheDict[Keys.S2],
            let id = cacheDict[Keys.identifier]
            else {
                throw PCKeyCacheArchiverError.dataParsingError
        }
        
        guard let ke = Data(base64Encoded: ke_base64),
            let km = Data(base64Encoded: km_base64),
            let s1 = Data(base64Encoded: s1_base64),
            let s2 = Data(base64Encoded: s2_base64)
            else {
                throw PCKeyCacheArchiverError.dataParsingError
        }
        guard let identifier = ECIESConfigIdentifier(rawValue: id) else {
            throw PCKeyCacheArchiverError.unknownIdentifier
        }
        let config = factory.genECIESConfig(identifier: identifier, s1, s2)
        let cache = PCKeyCache(Ke: ke, Km: km, config: config)
        return cache
    }
}
