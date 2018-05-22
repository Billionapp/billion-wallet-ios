//
//  TxGenerator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxGenerator {
    func transactionsForAmount(_ amount: UInt64, feeRate satPerByte: UInt64) throws -> [Transaction]
    func totalFeeForAmount(_ amount: UInt64, feeRate satPerByte: UInt64) throws -> UInt64
}

extension TxGenerator {
    func totalFeeForAmount(_ amount: UInt64, feeRate satPerByte: UInt64) throws -> UInt64 {
        let signatureSize = 72
        
        var txSize: UInt64 = 0
        let txs = try transactionsForAmount(amount, feeRate: satPerByte)
        for tx in txs {
            txSize += UInt64(tx.size)
            if !tx.isSigned {
                txSize += UInt64(tx.outputs.count*signatureSize)
            }
        }
        
        let feeAmount = UInt64(txSize * satPerByte)
        return feeAmount
    }
}

enum TxGeneratorError: LocalizedError {
    case couldNotCreateOutput
    
    var errorDescription: String? {
        switch self {
        case .couldNotCreateOutput:
            return "Could not create output for transaction"
        }
    }
}
