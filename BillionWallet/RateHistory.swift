//
//  RateHistory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct RateHistory: Codable {
    /// Transaction timestamp
    let blockTimestamp: Int64
    /// Rates, valid for the moment `txts`
    let rates: [Rate]
}
