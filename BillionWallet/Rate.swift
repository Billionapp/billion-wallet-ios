//
//  Rates.swift
//  Rates
//
//  Created by Evolution Group Ltd on 13.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import Darwin

/// BTC rate, valid on a given point of time
struct Rate: Codable {
    /// Currency ISO code
    let currencyCode: String
    /// Fiat currency for 1 BTC
    let btc: Double
    /// Timestamp in API response (a time on which this rate is considered valid)
    var rateTimestamp: Int64 = 0
    
    init(currencyCode: String, btc: Double, timestamp: Int64) {
        self.currencyCode = currencyCode
        self.btc = btc
        self.rateTimestamp = timestamp
    }
}
