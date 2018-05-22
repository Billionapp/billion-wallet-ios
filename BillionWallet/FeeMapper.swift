//
//  FeeMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

public enum FeeMapperError: LocalizedError {
    case incorrectData
}

protocol FeeMapper: class {
    func mapResult(from json: JSON) throws -> (fees: [FeeEstimate], timestamp: TimeInterval)
}
