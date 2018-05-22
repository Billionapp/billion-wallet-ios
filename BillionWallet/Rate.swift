//
//  Rate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct Rate: Codable {
    /// Currency ISO code
    let currencyCode: String
    /// Fiat currency for 1 BTC
    let btc: Double
    /// Timestamp in API response (a time on which this rate is considered valid)
    let blockTimestamp: Int64
}
