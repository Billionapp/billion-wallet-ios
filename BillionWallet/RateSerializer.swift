//
//  RateSerializer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RateSerializer: RateSerializerProtocol {
    
    func serializeToData(_ rateHistory: RateHistory) throws -> Data {
        let data = try JSONEncoder().encode(rateHistory)
        return data
    }
    
    func deserializeFromData(_ data: Data) throws -> RateHistory {
        let rateHistory = try JSONDecoder().decode(RateHistory.self, from: data)
        return rateHistory
    }

}
