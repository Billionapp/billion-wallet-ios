//
//  PCMaxAmountBuilder.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PCMaxAmountBuilder: MaxSendAmountBuilder {
    let minimumAmount: UInt64 = 6000
    
    private let walletProvider: WalletProvider
    private let contact: PaymentCodeContactProtocol
    private let feeProvider: FeeProvider
    private let notificationSizeApproximizer: TxSizeApproximizer
    private let regularSizeApproximizer: TxSizeApproximizer
    
    init(walletProvider: WalletProvider,
         contact: PaymentCodeContactProtocol,
         feeProvider: FeeProvider,
         notificationSizeApproximizer: TxSizeApproximizer,
         regularSizeApproximizer: TxSizeApproximizer) {
        
        self.walletProvider = walletProvider
        self.contact = contact
        self.feeProvider = feeProvider
        self.notificationSizeApproximizer = notificationSizeApproximizer
        self.regularSizeApproximizer = regularSizeApproximizer
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
        
        let lowestFee = try feeProvider.getFee(size: .low).maxFee
        let recommendedFee = try feeProvider.getFee(size: .high).maxFee
        
        var txSize = 0
        if contact.isNotificationTxNeededToSend {
            txSize += notificationSizeApproximizer.txSizeFor(inputCount: utxosCount/2, outputCount: 1)
            txSize += regularSizeApproximizer.txSizeFor(inputCount: utxosCount + 1 - utxosCount/2, outputCount: 2)
        } else {
            txSize = regularSizeApproximizer.txSizeFor(inputCount: utxosCount, outputCount: 2)
        }
        
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
