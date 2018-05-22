//
//  TxPostNoop.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxPostNoop: TxPostPublish {
    func performPostPublishTasks(_ transactions: [Transaction]) {  }
}
