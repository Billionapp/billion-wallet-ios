//
//  TxPostPublisher.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TxPostPublisher {
    
    let successPostPublishTasks: [TxPostPublish]
    let failurePostPublishTasks: [TxPostPublish]
    
    init(successPostPublishTasks: [TxPostPublish], failurePostPublishTasks: [TxPostPublish]) {
        self.successPostPublishTasks = successPostPublishTasks
        self.failurePostPublishTasks = failurePostPublishTasks
    }
    
    func runAfterSuccess(transactions: [Transaction]) {
        for task in successPostPublishTasks {
            task.performPostPublishTasks(transactions)
        }
    }
    
    func runAfterFailure(transactions: [Transaction]) {
        for task in failurePostPublishTasks {
            task.performPostPublishTasks(transactions)
        }
    }
}
