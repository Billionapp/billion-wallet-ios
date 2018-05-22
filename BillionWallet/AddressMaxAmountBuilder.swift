//
//  AddressMaxAmountBuilder.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AddressMaxAmountBuilder: MaxSendAmountBuilder {
    let minimumAmount: UInt64 = 6000
    
    private var walletProvider: WalletProvider
    private var feeProvider: FeeProvider
    private var sizeApproximizer: TxSizeApproximizer
    
    init(walletProvider: WalletProvider,
         feeProvider: FeeProvider,
         sizeApproximizer: TxSizeApproximizer) {
        
        self.walletProvider = walletProvider
        self.feeProvider = feeProvider
        self.sizeApproximizer = sizeApproximizer
    }
    
    func zeroMaxSendAmount() -> MaxSendAmount {
        var balance: UInt64 = 0
        do {
            let wallet = try walletProvider.getWallet()
            for output in wallet.unspentOutputs {
                let allTx = wallet.getAllTxs()
                if let tx = allTx[UInt256S(output.hash)] {
                    let btx = Transaction(brTransaction: tx, walletProvider: walletProvider)
                    balance += btx.outputAmounts[Int(output.n)]
                }
            }
        } catch {
            Logger.warn("No wallet")
        }
        return MaxSendAmount(minimumAmount: 0,
                             safeMaxAmount: 0,
                             unsafeMaxAmount: 0,
                             balanceAmount: balance)
    }
    
    func buildMaxSendAmount() throws -> MaxSendAmount {
        let wallet = try walletProvider.getWallet()
        
        var balance: UInt64 = 0
        var utxosCount: UInt64 = 0
        for output in wallet.unspentOutputs {
            let allTx = wallet.getAllTxs()
            if let tx = allTx[UInt256S(output.hash)] {
                let btx = Transaction(brTransaction: tx, walletProvider: walletProvider)
                balance += btx.outputAmounts[Int(output.n)]
                utxosCount += 1
            }
        }
        
        let lowestFee = try feeProvider.getFee(size: .low).minFee
        let recommendedFee = try feeProvider.getFee(size: .high).maxFee
        
        let txSize = sizeApproximizer.txSizeFor(inputCount: utxosCount, outputCount: 2)
        let safeFeeAmount = UInt64(txSize * recommendedFee)
        let recommendedFeeAmount = UInt64(txSize * lowestFee)
        
        let balanceAmount = balance
        let safeMaxAmount = balance > safeFeeAmount ? balance - safeFeeAmount : 0
        let unsafeMaxAmount = balance > recommendedFeeAmount ? balance - recommendedFeeAmount : 0
        
        return MaxSendAmount(minimumAmount: minimumAmount,
                             safeMaxAmount: safeMaxAmount,
                             unsafeMaxAmount: unsafeMaxAmount,
                             balanceAmount: balanceAmount)
    }
}
