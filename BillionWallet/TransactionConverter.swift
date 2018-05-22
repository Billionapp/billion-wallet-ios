//
//  TransactionConverter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TransactionConverter {
    private var walletProvider: WalletProvider
    
    init(walletProvider: WalletProvider) {
        self.walletProvider = walletProvider
    }

    func createTransaction(for brTransaction: BRTransaction) -> Transaction {
        return Transaction(brTransaction: brTransaction, walletProvider: walletProvider)
    }
    
    func createTransaction(for brTransaction: BRTransaction, direction: Transaction.Direction) -> Transaction {
        return Transaction(brTransaction: brTransaction, walletProvider: walletProvider, direction: direction)
    }
}
