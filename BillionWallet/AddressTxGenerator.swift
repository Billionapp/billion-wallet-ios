//
//  AddressTxGenerator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddressTxGenerator: TxGenerator {
    private let walletProvider: WalletProvider
    private let address: String
    private let txBuilder: TransactionBuilder
    
    init(walletProvider: WalletProvider, txBuilder: TransactionBuilder, address: String) {
        self.walletProvider = walletProvider
        self.address = address
        self.txBuilder = txBuilder
    }
    
    func transactionsForAmount(_ amount: UInt64, feeRate satPerByte: UInt64) throws -> [Transaction] {
        let wallet = try walletProvider.getWallet()
        
        let brutxos = wallet.unspentOutputs
        let converter = BRUTXOCoverter(walletProvider: walletProvider)
        let utxos = converter.convert(brutxos: brutxos)
        guard let output = TxOutput(address: address, amount: amount) else {
            throw TxGeneratorError.couldNotCreateOutput
        }
        let transaction = try txBuilder.transaction(to: [output], using: utxos, feeRate: satPerByte)
        
        return [ transaction ]
    }
}
