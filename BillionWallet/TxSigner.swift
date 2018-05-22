//
//  TxSigner.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxSigner {
    func signTransactions(_ transactions: [Transaction]) -> Bool
}

class StandardTxSigner: TxSigner {
    private let walletProvider: WalletProvider
    
    init(walletProvider: WalletProvider) {
        self.walletProvider = walletProvider
    }
    
    private func sign(_ transaction: Transaction) -> Bool {
        guard let wallet = try? walletProvider.getWallet() else { return false }
        let privKeys = transaction.inputAddresses.flatMap {
            return wallet.privateKey(forAddress: $0)
        }
        return transaction.signWithPrivateKeys(privKeys)
    }
    
    func signTransactions(_ transactions: [Transaction]) -> Bool {
        for tx in transactions {
            if tx.isSigned {
                continue
            }
            let result = sign(tx)
            if !result {
                return false
            }
        }
        return true
    }
}
