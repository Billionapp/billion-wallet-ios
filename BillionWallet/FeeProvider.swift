//
//  FeeProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum FeeProviderError: LocalizedError {
    case feeNotLoaded
    
    var errorDescription: String? {
        switch self {
        case .feeNotLoaded:
            return Strings.OtherErrors.Fee.notLoaded
        }
    }
}

class FeeProvider {
    private let defaultDownloader: FeeDownloader
    private let fallbackDownloader: FeeDownloader
    private let defaultMapper: FeeMapper
    private let fallbackMapper: FeeMapper
    private let filter: FeeFilter
    
    private var timer: Timer?
    private var feeCache: FeeCacheService
    
    init(defaultDownloader: FeeDownloader,
         fallbackDownloader: FeeDownloader,
         defaultMapper: FeeMapper,
         fallbackMapper: FeeMapper,
         filter: FeeFilter,
         feeCache: FeeCacheService) {
        
        self.defaultDownloader = defaultDownloader
        self.fallbackDownloader = fallbackDownloader
        self.defaultMapper = defaultMapper
        self.fallbackMapper = fallbackMapper
        self.filter = filter
        self.feeCache = feeCache
    }
    
    private lazy var defaultDownloadSuccess: (JSON) -> Void = { [unowned self] data in
        Logger.debug("Fee main download ended")
        var result: (fees: [FeeEstimate], timestamp: TimeInterval)
        do {
            result = try self.defaultMapper.mapResult(from: data)
            Logger.debug("Fee main download mapping ended")
        } catch let error {
            Logger.warn("Main download fee result parsing was unsuccessful: \(error.localizedDescription)")
            self.downloadFeeFallback()
            return
        }
        self.updateCache(timestamp: result.timestamp, fees: result.fees)
    }
    
    private lazy var defaultDownloadError: (Error) -> Void = { [unowned self] error in
        Logger.warn("Fee main download error: \(error.localizedDescription)")
        self.downloadFeeFallback()
    }
    
    private lazy var fallbackDownloadSuccess: (JSON) -> Void = { [unowned self] data in
        var result: (fees: [FeeEstimate], timestamp: TimeInterval)
        do {
            result = try self.fallbackMapper.mapResult(from: data)
        } catch let error {
            Logger.error("Fallback download fee result parsing was unsuccessful: \(error.localizedDescription)")
            return
        }
        self.updateCache(timestamp: result.timestamp, fees: result.fees)
    }
    
    private lazy var fallbackDownloadError: (Error) -> Void = { [unowned self] error in
        Logger.error("Fee fallback download errror: \(error.localizedDescription)")
    }
    
    private func updateCache(timestamp: TimeInterval, fees: [FeeEstimate]) {
        if timestamp > feeCache.timestamp {
            Logger.debug("Starting cache update")
            let filteredFees = filter.filtered(fees)
            feeCache.setFees(fees: filteredFees, timestamp: timestamp)
            
            if let firstFee = feeCache.fees.first {
                Logger.info("Fees update: \(firstFee)")
            }
        } else {
            Logger.debug("Fee cache not updated because of old timestamp. Cached: \(feeCache.timestamp), new: \(timestamp)")
        }
    }
    
    var feeEstimates: [FeeEstimate] {
        return feeCache.fees
    }
    
    @objc func downloadFee() {
        Logger.debug("Fee main download starting")
        defaultDownloader.downloadFee(defaultDownloadSuccess, failure: defaultDownloadError)
    }
    
    func downloadFeeFallback() {
        fallbackDownloader.downloadFee(fallbackDownloadSuccess, failure: fallbackDownloadError)
    }
    
    // Get fee for fee size except custom fee
    func getFee(size: FeeSize) throws -> FeeEstimate {
        if feeCache.fees.count == 0 {
            throw FeeProviderError.feeNotLoaded
        }
        switch size {
        case .low:
            let lowestFee = feeCache.fees.first!
            return lowestFee
        case .high:
            let highestFee = feeCache.fees.last!
            return highestFee
        default:
            let highestFee = feeCache.fees.last!
            return highestFee
        }
    }
}

//MARK: - Timer
extension FeeProvider {
    func startTimer() {
        Logger.debug("Fee timer is fired")
        downloadFee()
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(downloadFee), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let timer = timer {
            timer.invalidate()
            Logger.info("Fee timer stopped")
        } else {
            Logger.debug("Attempt to stop fee timer while not active")
        }
    }
    
    func isFired() -> Bool {
        guard let t = timer else { return false }
        return t.isValid
    }
    
    func fireTimer() {
        if let timer = timer {
            timer.fire()
        } else {
            startTimer()
        }
    }
}
