//
//  TxPublisher.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxPublisher {
    func registerForPublish(_ transactions: [Transaction], success: @escaping () -> Void, failure: @escaping (Error) -> Void)
}

class NormalTxPublisher: TxPublisher {
    private let peerMan: BPeerManager
    
    init(peerMan: BPeerManager) {
        self.peerMan = peerMan
    }
    
    func registerForPublish(_ transactions: [Transaction], success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        // FIXME: Completion called on each tx
        for tx in transactions {
            tx.publish(using: peerMan, completion: { (err) in
                if let err = err {
                    Logger.error(err.localizedDescription)
                    failure(err)
                } else {
                    success()
                    Logger.info("Success publish: \(tx.txHashString)")
                }
            })
        }
    }
}

class SequentialTxPublisher: TxPublisher {
    private let peerMan: BPeerManager
    
    init(peerMan: BPeerManager) {
        self.peerMan = peerMan
    }
    
    func registerForPublish(_ transactions: [Transaction], success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        // FIXME: assuming just two tx
        guard let firstTx = transactions.first,
            let secondTx = transactions.last else {
            return
        }

        firstTx.publish(using: peerMan) { (err) in
            if let err = err {
                Logger.error(err.localizedDescription)
                failure(err)
            } else {
                Logger.info("Transaction published \(firstTx)")
                if transactions.count > 1 {
                    self.registerNextTransaction(secondTx, success: success, failure: failure)
                } else {
                    success()
                }
            }
        }
    }
    
    func registerNextTransaction(_ tx: Transaction, success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        tx.publish(using: peerMan) { (err) in
            if let err = err {
                Logger.error(err.localizedDescription)
                failure(err)
            } else {
                Logger.info("Transaction published \(tx)")
                success()
            }
        }
    }
}
