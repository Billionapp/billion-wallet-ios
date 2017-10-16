//
//  TransactionFee.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct TransactionFee {
    
    var maxFee: Int?
    var minDelay: Int?
    var transactionSize: Int?
    
    var estematedFee: Int? {
        guard let maxFee = maxFee, let transactionSize = transactionSize else {
            return nil
        }
        
        return maxFee/2 * transactionSize
    }
    
    var estematedSatoshiPerByte: Int? {
        guard let maxFee = maxFee else {
            return nil
        }
        
        return maxFee/2
    }
    
    var estematedMinutes: Int? {
        guard let minDelay = minDelay else {
            return nil
        }
        return minDelay * 10
    }
    
    init(json: JSON, transactionSize: Int?) {
        maxFee = json["maxFee"].intValue
        minDelay = json["minDelay"].intValue
        self.transactionSize = transactionSize
    }
    
}
