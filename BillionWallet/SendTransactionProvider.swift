//
//  SendTransactionProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SendTransactionProvider {
    
    let txGenerator: TxGenerator
    let txSigner: TxSigner
    let txPublisher: TxPublisher
    let txPostPublisher: TxPostPublisher
    let feeProvider: FeeProvider
    
    init(txGenerator: TxGenerator, txSigner: TxSigner, txPublisher: TxPublisher, txPostPublisher: TxPostPublisher, feeProvider: FeeProvider) {
        self.txGenerator = txGenerator
        self.txSigner = txSigner
        self.txPublisher = txPublisher
        self.txPostPublisher = txPostPublisher
        self.feeProvider = feeProvider
    }
    
    // MARK: - TxGenerator
    func totalFeeForAmount(_ amount: UInt64, feeRate satPerByte: UInt64) -> UInt64 {
        var totalFee: UInt64 = 0
        do {
            totalFee = try txGenerator.totalFeeForAmount(amount, feeRate: satPerByte)
        } catch let error {
            Logger.debug("\(error.localizedDescription)")
        }
        
        return totalFee
    }
    
    func prepareTransactions(_ amount: UInt64, feeRate satPerByte: UInt64) throws -> (txs: [Transaction], totalAmount: UInt64, totalFee: UInt64) {
        let txs = try txGenerator.transactionsForAmount(amount, feeRate: satPerByte)
        guard txs.count > 0 else {
            throw SendTransactionProviderError.insufficientFunds
        }
        let signOk = txSigner.signTransactions(txs)
        if signOk {
            var totalAmount: UInt64 = 0
            var totalFee: UInt64 = 0
            for tx in txs {
                totalAmount += tx.amount
                totalFee += tx.fee
            }
            return (txs: txs, totalAmount: totalAmount, totalFee: totalFee)
        } else {
            throw SendTransactionProviderError.cannotSign(txs: txs)
        }
    }
    
    // MARK: - PostPublisher
    func runSuccessPostPublishTasks(for transaction: [Transaction]) {
        txPostPublisher.runAfterSuccess(transactions: transaction)
    }
    
    func runFailurePostPublishTasks(for transaction: [Transaction]) {
        txPostPublisher.runAfterFailure(transactions: transaction)
    }
    
    // MARK: - Publisher
    func registerForPublish(_ transactions: [Transaction], success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        txPublisher.registerForPublish(transactions, success: success, failure: failure)
    }

}

enum SendTransactionProviderError: Error, LocalizedError {
    case insufficientFunds
    case cannotSign(txs: [Transaction])
    
    var errorDescription: String? {
        switch self {
        case .insufficientFunds:
            return "Insufficient funds"
        case .cannotSign(let txs):
            return "Cannot sign transactions: \(txs)"
        }
    }
}
