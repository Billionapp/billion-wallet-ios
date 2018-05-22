//
//  RateMapperProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol RateSerializerProtocol {
    func serializeToData(_ rateHistory: RateHistory) throws -> Data
    func deserializeFromData(_ data: Data) throws -> RateHistory
}
