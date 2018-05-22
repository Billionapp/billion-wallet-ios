//
//  ChatKeysStorage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol SecureDataStorage {
    func store(_ data: Data, forKey key: String)
    func load(key: String) -> Data?
}

class KeychainDataStorage: SecureDataStorage {
    private let keychain: Keychain = Keychain()
    
    func store(_ data: Data, forKey key: String) {
        keychain.setData(data, forKey: key)
    }
    
    func load(key: String) -> Data? {
        return keychain.getData(forKey: key)
    }
}
