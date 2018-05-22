//
//  TxPostDeleteFailureTransaction.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxPostDeleteFailureTransaction: TxPostPublish {
    
    let failureTransaction: FailureTx
    let failureTxProvider: FailureTxProtocol
    
    init(failureTransaction: FailureTx, failureTxProvider: FailureTxProtocol) {
        self.failureTransaction = failureTransaction
        self.failureTxProvider = failureTxProvider
    }
    
    func performPostPublishTasks(_ transactions: [Transaction]) {
        failureTxProvider.deleteFailureTx(identifier: failureTransaction.identifier, completion: {
            Logger.info("Failure transaction deleted")
        }) { error in
            Logger.error(error.localizedDescription)
        }
    }
}
