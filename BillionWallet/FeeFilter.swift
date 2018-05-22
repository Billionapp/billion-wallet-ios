//
//  FeeFilter.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// A filter for fee estimates to perform calculations on raw estimates prior to using them
protocol FeeFilter {
    /// Perform calculations on raw fee estimates to choose subset or mutate them
    ///
    /// - Parameter fees: raw fee estimates
    /// - Returns: filtered fee estimates
    func filtered(_ fees: [FeeEstimate]) -> [FeeEstimate]
}

/// Standard fee filter (estimates fee value in acceptance range 12h - 10m)
class StandardFeeFilter: FeeFilter {
    /// 72 blocks = 720 minutes = 12h
    private let lowestDelay = 72
    private let maxDelay = 1
    private let maxDelayOffset = 0
    
    func filtered(_ fees: [FeeEstimate]) -> [FeeEstimate] {
        let fees = fees.sorted { return $0.minFee < $1.minFee }
        var firstIndex = fees.index { $0.maxDelay <= self.lowestDelay }
        if firstIndex == nil {
            firstIndex = fees.startIndex
        }
        var lastIndex = fees.index { $0.maxDelay <= self.maxDelay }
        if lastIndex == nil {
            lastIndex = fees.endIndex-1
        }
        if lastIndex != fees.endIndex-1 {
            lastIndex = min(lastIndex!+maxDelayOffset, fees.endIndex-1)
        }
        return [FeeEstimate](fees[firstIndex!...lastIndex!])
    }
}

/// Plan B fee filter, that ensures that last estimate size is not too high
class ReserveFeeFilter: FeeFilter {
    /// 72 blocks = 720 minutes = 12h
    private let lowestDelay = 72
    private let maxDelay = 1
    private let maxDelayOffset = 0
    
    func filtered(_ fees: [FeeEstimate]) -> [FeeEstimate] {
        let fees = fees.sorted { return $0.minFee < $1.minFee }
        var firstIndex = fees.index { $0.maxDelay <= self.lowestDelay }
        if firstIndex == nil {
            firstIndex = fees.startIndex
        }
        var lastIndex = fees.index { $0.maxDelay <= self.maxDelay }
        if lastIndex == nil {
            lastIndex = fees.endIndex-1
        }
        if lastIndex != fees.endIndex-1 {
            lastIndex = min(lastIndex!+maxDelayOffset, fees.endIndex-1)
        }
        
        // WARNING! Hardcoded logic, that depends strongly on received data structure
        var resultFees: [FeeEstimate] = []
        for f in fees[firstIndex!...lastIndex!] {
            var fee = f
            if f.minFee + 10 < f.maxFee {
                fee = FeeEstimate(avgTime: f.avgTime,
                                  minDelay: f.minDelay,
                                  maxDelay: f.maxDelay,
                                  minFee: f.minFee,
                                  maxFee: f.minFee + 9)
            }
            resultFees.append(fee)
        }
        return resultFees
    }
}
