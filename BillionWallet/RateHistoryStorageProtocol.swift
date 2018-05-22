//
//  RateHistoryStorageProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol RateHistoryStorageProtocol {
    func getRateHistory(forTimestamp timestamp: Int64) throws -> RateHistory
    func update(with rateHistory: RateHistory) throws
    func existingTimestamps() throws -> Set<Int64>
    func getMaxTimestamp() throws -> Int64?
    func delete(forTimestamp timestamp: Int64) throws
}
