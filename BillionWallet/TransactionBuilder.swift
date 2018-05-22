//
//  TransactionBuilder.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TransactionBuilder {
    func transaction(to txOutputs: [TxOutput], using utxos: [UTXO], feeRate satPerByte: UInt64, sizeGap: UInt64) throws -> Transaction
}

extension TransactionBuilder {
    func transaction(to txOutputs: [TxOutput], using utxos: [UTXO], feeRate satPerByte: UInt64, sizeGap: UInt64 = 0) throws -> Transaction {
        return try transaction(to: txOutputs, using: utxos, feeRate: satPerByte, sizeGap: sizeGap)
    }
}

class StandardTransactionBuilder: TransactionBuilder {
    private let walletProvider: WalletProvider
    private let txConverter: TransactionConverter
    
    init(wallet: WalletProvider) {
        self.walletProvider = wallet
        self.txConverter = TransactionConverter(walletProvider: wallet)
    }
    
    func transaction(to txOutputs: [TxOutput], using utxos: [UTXO], feeRate satPerByte: UInt64, sizeGap: UInt64) throws -> Transaction {
        let wallet = try walletProvider.getWallet()
        
        let outputSize: UInt64 = 34
        
        var totalAmount: UInt64 = 0
        var balance: UInt64 = 0
        let transaction = BRTransaction()
        var feeAmount: UInt64 = 0
        var changeAmount: UInt64 = 0
        
        for txOutput in txOutputs {
            transaction.addOutputScript(txOutput.script, amount: txOutput.amount)
            totalAmount += txOutput.amount
        }
        
        for utxo in utxos {
            transaction.addInputHash(utxo.txHash.uint256, index: utxo.index, script: utxo.lockScript)
            
            balance += utxo.amount
            
            if satPerByte > 0 {
                let size = UInt64(transaction.size) + outputSize + sizeGap   // + change output
                feeAmount = size*satPerByte
            }
            
            if balance == totalAmount + feeAmount ||
                balance >= totalAmount + feeAmount + wallet.minOutputAmount {
                break
            }
        }
        
        if balance < totalAmount + feeAmount {
            Logger.debug(String(format: "Insufficient funds. %llu is less than transaction amount: %llu", balance, totalAmount + feeAmount))
            throw TransactionBuilderError.insufficientFunds(required: totalAmount + feeAmount, got: balance)
        }
        
        let remainder = balance - (totalAmount + feeAmount)
        if remainder >= wallet.minOutputAmount {
            changeAmount = remainder
            transaction.addOutputAddress(wallet.changeAddress, amount: changeAmount)
        } else {
            feeAmount += remainder
        }
        
        let resultTx = txConverter.createTransaction(for: transaction, direction: .sent)
        resultTx.sent = balance
        resultTx.received = changeAmount
        resultTx.fee = feeAmount
        return resultTx
    }
}

enum TransactionBuilderError: LocalizedError {
    case insufficientFunds(required: UInt64, got: UInt64)
    
    var errorDescription: String? {
        switch self {
        case .insufficientFunds(let required, let got):
            return "Insufficient funds. \(got) is less than transaction amount: \(required)"
        }
    }
}
