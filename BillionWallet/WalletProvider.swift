//
//  WalletProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

@objc
class WalletProvider: NSObject {
    
    private let manager: BRWalletManager
    let peerManager: BRPeerManager
    
    init(manager: BRWalletManager, peerManager: BRPeerManager) {
        self.manager = manager
        self.peerManager = peerManager
    }
    
    func getWallet() throws -> BWallet {
        guard let wallet = manager.wallet else {
            throw Table()
        }
        return BreadWallet(brWallet: wallet)
    }
    
    private lazy var walletManager: BWalletManager = {
        return BreadWalletManager(brWalletManager: manager)
    }()
    
    private lazy var bPeerManager: BPeerManager = {
        return BreadPeerManager(brPeerManager: peerManager)
    }()
    
    func getSeedData() -> Data? {
        guard let seedPhrase = BRWalletManager.getMnemonicKeychainString() else {
            return nil
        }
        return BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil)
    }
}

extension WalletProvider: BWalletManager {
    var noWallet: Bool {
        return walletManager.noWallet
    }
    
    var seedPhrase: String? {
        return walletManager.seedPhrase
    }
    
    var seedCreationTime: TimeInterval {
        return walletManager.seedCreationTime
    }
    
    var isTestnet: Bool {
        return walletManager.isTestnet
    }
    
    func generateRandomSeed() -> String? {
        return walletManager.generateRandomSeed()
    }
    
    func recoverWallet(withPhrase phrase: String) throws {
        return try walletManager.recoverWallet(withPhrase: phrase)
    }
}

// MARK: - BPeerManager
extension WalletProvider: BPeerManager {
    
    var lastBlockHeight: UInt32 {
        return bPeerManager.lastBlockHeight
    }
    
    var estimatedBlockHeight: UInt32 {
        return bPeerManager.estimatedBlockHeight
    }
    
    var syncProgress: Double {
        return bPeerManager.syncProgress
    }
    
    var lastSyncCache: Double {
        get {
            return peerManager.lastSyncCache
        } set (_lastSyncCache) {
            peerManager.lastSyncCache = _lastSyncCache
        }
    }
    
    func connect() {
        bPeerManager.connect()
    }
    
    func rescan() {
        bPeerManager.rescan()
    }
    
    func rescan(from startHeight: UInt32) {
        bPeerManager.rescan(from: startHeight)
    }
    
    func lastBlock() -> BRMerkleBlock {
        return bPeerManager.lastBlock()
    }
    
    func publishTransaction(_ transaction: Transaction, complition: @escaping (Error?) -> Void) {
        bPeerManager.publishTransaction(transaction, complition: complition)
    }
    
    func isConnectedToDownloadPeer() -> Bool {
        return bPeerManager.isConnectedToDownloadPeer()
    }

}
