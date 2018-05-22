//
//  TxPublisherFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxPublisherFactory {
    func publisher() -> TxPublisher
}

class DefaultTxPublisherFactory: TxPublisherFactory {
    private let peerMan: BPeerManager
    
    init(peerMan: BPeerManager) {
        self.peerMan = peerMan
    }
    
    func publisher() -> TxPublisher {
        return NormalTxPublisher(peerMan: peerMan)
    }
}

class PCTxPublisherFactory: TxPublisherFactory {
    private let peerMan: BPeerManager
    
    init(peerMan: BPeerManager) {
        self.peerMan = peerMan
    }
    
    func publisher() -> TxPublisher {
        return SequentialTxPublisher(peerMan: peerMan)
    }
}
