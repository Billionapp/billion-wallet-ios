//
//  FeeVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol FeeVMDelegate: class {
    func didChange(to: TransactionFee)
    func didFeeRequestFailed()
}

class FeeVM {
    
    typealias Completion = (Fee?) -> Void

    let networkProvider: NetworkProvider
    let walletProvider: WalletProvider
    weak var txProvider: TransactionProvider?
    weak var delegate: FeeVMDelegate?
    var completion: Completion?
    var transaction: BRTransaction?
    
    var amount: Int? {
        guard let brTransaction = transaction else {
            return nil
        }
        
        let tx = Transaction(brTransaction: brTransaction, contact: nil, isNotificationTx: false, rates: [])
        return abs(Int(tx.amount))
    }
    
    var selectedTransactionFee: TransactionFee? {
        didSet {
            guard let selectedTransactionFee = selectedTransactionFee else { return }
            delegate?.didChange(to: selectedTransactionFee)
        }
    }
    
    var maxValue: Float?
    var minValue: Float?
    
    var transactionsFees: [TransactionFee]?
    
    // MARK: - Lifecycle
    init(walletProvider: WalletProvider, networkProvider: NetworkProvider, txProvider: TransactionProvider, transaction: BRTransaction?, completion: Completion?) {
        self.walletProvider = walletProvider
        self.networkProvider = networkProvider
        self.txProvider = txProvider
        self.transaction = transaction
        self.completion = completion
    }
    
    func valueDidChanged(value: Float) {
        guard let transactionsFees = transactionsFees else {
            return
        }
        selectedTransactionFee = transactionsFees[Int(Float(transactionsFees.count - 1) * value)]
    }
    
    func localCurrencyString(for amount: Int64) -> String {
        return walletProvider.manager.localCurrencyString(forAmount: amount)
    }
    
    func getTransactionFee() {
        PopupView.loading.showLoading()
        API(network: networkProvider).getListForCustomFee(transactionSize: transaction?.size, failure: { [weak self] error in
            PopupView.loading.dismissLoading()
            self?.delegate?.didFeeRequestFailed()
        }) { [weak self] transactionsFees in
            PopupView.loading.dismissLoading()
            var minDelayCount = 0
            self?.transactionsFees = transactionsFees.filter { fee in
                if fee.minDelay == 0 {
                    minDelayCount += 1
                }
                return minDelayCount <= 2
            }
            self?.transactionsFees?.removeFirst()
            self?.selectedTransactionFee = transactionsFees.first
        }
    }
    
    func sendTransaction() {
        guard let satPerByte = selectedTransactionFee?.estematedSatoshiPerByte,
            let confirmTime = selectedTransactionFee?.estematedMinutes else {
            return
        }
        
        let fee = Fee(size: .custom, satPerByte: satPerByte, confirmTime: confirmTime)
        completion?(fee)
    }
}
