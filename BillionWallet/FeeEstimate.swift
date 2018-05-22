//
//  FeeEstimate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct FeeEstimate: Codable {
    let avgTime: Int
    let minDelay: Int
    let maxDelay: Int
    let minFee: Int
    let maxFee: Int
}
