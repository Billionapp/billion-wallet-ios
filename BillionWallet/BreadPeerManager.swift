//
//  BreadPeerManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08.02.18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BreadPeerManager: BPeerManager {
    let brPeerManager: BRPeerManager
    
    init(brPeerManager: BRPeerManager) {
        self.brPeerManager = brPeerManager
    }
    
    var lastBlockHeight: UInt32 {
        return brPeerManager.lastBlockHeight
    }
    
    var estimatedBlockHeight: UInt32 {
        return brPeerManager.estimatedBlockHeight
    }
    
    var syncProgress: Double {
        return brPeerManager.syncProgress
    }
    
    var lastSyncCache: Double {
        return brPeerManager.lastSyncCache
    }
    
    func connect() {
        brPeerManager.connect()
    }
    
    func rescan() {
        brPeerManager.rescan()
    }
    
    func rescan(from startHeight: UInt32) {
        brPeerManager.rescan(from: startHeight)
    }
    
    func lastBlock() -> BRMerkleBlock {
        return brPeerManager.lastBlock()
    }
    
    func publishTransaction(_ transaction: Transaction, complition: @escaping (Error?) -> Void) {
        brPeerManager.publishTransaction(transaction.brTransaction, completion: complition)
    }
    
    func isConnectedToDownloadPeer() -> Bool {
        return brPeerManager.isConnectedToDownloadPeer()
    }
}
