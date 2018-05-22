//
//  UTXO.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct UTXO: Hashable {
    let txHash: UInt256S
    let index: UInt
    let amount: UInt64
    let lockScript: Data?
    
    var hashValue: Int {
        return txHash.data.hashValue
    }
    
    static func ==(lhs: UTXO, rhs: UTXO) -> Bool {
        return lhs.txHash.data == rhs.txHash.data &&
            lhs.index == rhs.index
    }
}

class BRUTXOCoverter {
    private let walletProvider: WalletProvider
    
    init(walletProvider: WalletProvider) {
        self.walletProvider = walletProvider
    }
    
    func convert(brutxo: BRUTXO) -> UTXO? {
        guard let wallet = try? walletProvider.getWallet() else { return nil }
        
        let txHash = UInt256S(brutxo.hash)
        let index = brutxo.n
        let allTxs = wallet.getAllTxs()
        guard let tx = allTxs[UInt256S(brutxo.hash)] else {
            return nil
        }
        let btx = Transaction(brTransaction: tx, walletProvider: walletProvider)
        let amount = btx.outputAmounts[Int(brutxo.n)]
        let lockScript = btx.outputScripts[Int(brutxo.n)]
        return UTXO(txHash: txHash, index: index, amount: amount, lockScript: lockScript)
    }
    
    func convert(utxo: UTXO) -> BRUTXO {
        let hash256 = utxo.txHash.uint256
        let index = utxo.index
        return BRUTXO(hash: hash256, n: index)
    }
    
    func convert(brutxos: [BRUTXO]) -> [UTXO] {
        return brutxos.flatMap { self.convert(brutxo: $0) }
    }
    
    func convert(utxos: [UTXO]) -> [BRUTXO] {
        return utxos.map { self.convert(utxo: $0) }
    }
}
