//
//  TxPostPublish.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxPostPublish {
    func performPostPublishTasks(_ transactions: [Transaction])
}
