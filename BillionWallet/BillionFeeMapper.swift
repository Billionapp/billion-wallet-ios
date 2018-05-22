//
//  BillionFeeMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BillionFeeMapper: FeeMapper {
    private let factory: FeeFactory
    
    init(factory: FeeFactory) {
        self.factory = factory
    }
    
    func mapResult(from json: JSON) throws -> (fees: [FeeEstimate], timestamp: TimeInterval) {
        let timestamp = json["timestamp"].doubleValue
        var fees: [FeeEstimate] = []
        for feeJson in json["fees"].arrayValue {
            let fee = factory.createFee(minDelay: feeJson["minDelay"].intValue,
                                        maxDelay: feeJson["maxDelay"].intValue,
                                        minFee: feeJson["minFee"].intValue,
                                        maxFee: feeJson["maxFee"].intValue)
            fees.append(fee)
        }
        if fees.count == 0 {
            throw FeeMapperError.incorrectData
        }
        return (fees: fees, timestamp: timestamp)
    }
}
