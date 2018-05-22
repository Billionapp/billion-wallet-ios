//
//  FeeFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class FeeFactory {
    func createFee(minDelay: Int, maxDelay: Int, minFee: Int, maxFee: Int) -> FeeEstimate {
        return FeeEstimate(avgTime: max(1, maxDelay)*10,
                           minDelay: minDelay,
                           maxDelay: maxDelay,
                           minFee: minFee,
                           maxFee: maxFee)
    }
}
