//
//  PCv1TxGenerator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PCv1TxGenerator: TxGenerator {
    private let walletProvider: WalletProvider
    private let selfPc: PaymentCode
    private let pcContact: PaymentCodeContactProtocol
    private let txBuilder: TransactionBuilder
    
    init(walletProvider: WalletProvider, selfPc: PaymentCode, txBuilder: TransactionBuilder, pcContact: PaymentCodeContactProtocol) {
        self.walletProvider = walletProvider
        self.selfPc = selfPc
        self.pcContact = pcContact
        self.txBuilder = txBuilder
    }
    
    private func outputsConsumedByTransaction(_ transaction: Transaction) -> [BRUTXO] {
        var brutxos: [BRUTXO] = []
        for i in 0..<transaction.inputHashes.count {
            let hash256 = transaction.inputHashes[i]
            let index = transaction.inputIndexes[i]
            let brutxo = BRUTXO(hash: hash256.uint256, n: index)
            brutxos.append(brutxo)
        }
        return brutxos
    }
    
    func transactionsForAmount(_ amount: UInt64, feeRate satPerByte: UInt64) throws -> [Transaction] {
        let wallet = try walletProvider.getWallet()
        
        let brutxos = wallet.unspentOutputs
        let converter = BRUTXOCoverter(walletProvider: walletProvider)
        let utxos = converter.convert(brutxos: brutxos)
        
        let opReturnSize: UInt64 = 92
        
        guard let naOutput = TxOutput(address: pcContact.paymentCodeObject.notificationAddress!, amount: 13370) else {
            throw TxGeneratorError.couldNotCreateOutput
        }
        let notificationTx = try txBuilder.transaction(to: [naOutput],
                                                       using: utxos,
                                                       feeRate: satPerByte,
                                                       sizeGap: opReturnSize)
        
        let designatedInputAddress = notificationTx.inputAddresses[0]
        let privKeyStr = wallet.privateKey(forAddress: designatedInputAddress)!
        let privKeyData = Data(privKeyStr.base58checkAsData![1...32])
        
        let opReturnScript = selfPc.notificationOpReturnScript(for: pcContact.paymentCodeObject,
                                                               transaction: notificationTx,
                                                               key: Priv(data: privKeyData))
        notificationTx.addOutput(script: opReturnScript!, amount: 0)
        
        let privKeys = notificationTx.inputAddresses.flatMap {
            return wallet.privateKey(forAddress: $0)
        }
        let _ = notificationTx.signWithPrivateKeys(privKeys)
        
        // TxHash is unavailable before signing
        var newUtxos: [UTXO] = []
        if notificationTx.outputScripts.count > 2 {
            let changeOutputAmount = notificationTx.outputAmounts[1]
            newUtxos.append(UTXO(txHash: notificationTx.txHash,
                                 index: 1,
                                 amount: changeOutputAmount,
                                 lockScript: notificationTx.outputScripts[1]))
        }
        
        let consumedUtxos = outputsConsumedByTransaction(notificationTx)
        let notConsumed = Set<UTXO>(utxos).subtracting(converter.convert(brutxos: consumedUtxos))
        let regOutput = TxOutput(address: pcContact.addressToSend()!, amount: amount)
        if let regularTx = try? txBuilder.transaction(to: [regOutput!],
                                                      using: Array(notConsumed),
                                                      feeRate: satPerByte) {
            regularTx.shuffleOutputOrder()
            return [ notificationTx, regularTx ]
        }
        let regularTx = try txBuilder.transaction(to: [regOutput!],
                                                  using: Array(notConsumed.union(newUtxos)),
                                                  feeRate: satPerByte)
        regularTx.shuffleOutputOrder()
        return [ notificationTx, regularTx ]
    }
}
