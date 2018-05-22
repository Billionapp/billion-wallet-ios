//
//  BPeerManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08.02.18.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BPeerManager: class {
    var lastBlockHeight: UInt32 { get }
    var estimatedBlockHeight: UInt32 { get }
    var syncProgress: Double { get }
    var lastSyncCache: Double { get }
    
    func connect()
    func rescan()
    func rescan(from startHeight: UInt32)
    func lastBlock() -> BRMerkleBlock 
    func publishTransaction(_ transaction: Transaction, complition: @escaping (Error?) -> Void)
    func isConnectedToDownloadPeer() -> Bool
}
