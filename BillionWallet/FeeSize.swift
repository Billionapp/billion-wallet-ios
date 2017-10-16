//
//  FeeSize.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum FeeSize: String, Equatable {
    case high
    case normal
    case low
    case custom
    
    var description: String {
        return rawValue.capitalized
    }
    
    static var all: [FeeSize] {
        return [.high, .normal, .low, .custom]
    }
    
    static func ==(lhs: FeeSize, rhs: FeeSize) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
}



