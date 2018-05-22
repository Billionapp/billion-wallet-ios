//
//  TxPostPublishCreateFailureTx.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxPostPublishCreateFailureTx: TxPostPublish {
    
    let failureTxProvider: FailureTxProtocol
    let walletProvider: WalletProvider
    let contact: ContactProtocol?
    
    init(failureTxProvider: FailureTxProtocol,
         walletProvider: WalletProvider,
         contact: ContactProtocol?) {
        
        self.failureTxProvider = failureTxProvider
        self.walletProvider = walletProvider
        self.contact = contact
    }
    
    func performPostPublishTasks(_ transactions: [Transaction]) {
        for transaction in transactions {
            guard let address = getPartnerAddress(from: transaction) else { return }
            let amount = transaction.amount
            let fee = transaction.fee
            let id = contact?.uniqueValue ?? ""
            failureTxProvider.createFailureTx(address: address, amount: amount, fee: fee, comment: "", contactID: id, completion: {
                Logger.info("Successful create Failure")
            }, failure: { (error) in
                Logger.error(error.localizedDescription)
            })
        }
    }
    
    private func getPartnerAddress(from transaction: Transaction) -> String? {
        guard let wallet = try? walletProvider.getWallet() else { return nil }
        
        let outputsAddresses = transaction.outputAddresses
        let addressSet: Set<String> = Set(outputsAddresses)
        let changeSet = wallet.allChangeAddresses
        let firstNonWalletAddress = addressSet.first { !changeSet.contains($0) }
        return firstNonWalletAddress
    }
}
