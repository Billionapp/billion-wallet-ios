//
//  RateProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RateProvider: RateProviderProtocol {
    
    private let storage: RateHistoryStorageProtocol
    private let rateQueue: RateQueueProtocol
    private let api: API
    
    init(api: API, storage: RateHistoryStorageProtocol, rateQueue: RateQueueProtocol) {
        self.api = api
        self.storage = storage
        self.rateQueue = rateQueue
        
        addObservers()
    }
    
    func getRate(for currency: Currency, timestamp: TimeInterval) throws -> Rate {
        let time = Int64(timestamp)

        do {
            let rateHistory = try storage.getRateHistory(forTimestamp: time)
            let rates = rateHistory.rates
            let rate = try findRate(rates, for: currency)
            return rate
            
        } catch {
            switch error {
            case FileStorageError.readFailure:
                rateQueue.addOperation(with: time, completion: ratesHandler(timestamp: time))
                throw error
                
            default:
                let allCurrencies = CurrencyFactory.allowedCurrenies()
                if !allCurrencies.contains(currency) {
                    try storage.delete(forTimestamp: time)
                    rateQueue.addOperation(with: time, completion: ratesHandler(timestamp: time))
                }
                throw error
            }
        }
    }
    
    /// Geting last rate
    func getRate(for currency: Currency) throws -> Rate {
        let list = try storage.existingTimestamps()
        guard
            let timestamp = try storage.getMaxTimestamp() else {
                throw RateProviderError.currencyNotFound
        }
        
        let rates = try storage.getRateHistory(forTimestamp: timestamp).rates
        let rate = try findRate(rates, for: currency)
        return rate
    }
    
    // MARK: - Privates
    
    private func addObservers() {
        let name = Notification.Name.BRPeerManagerNewBlock
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNewBlock(_:)), name: name, object: nil)
        let lastName = Notification.Name.BRPeerManagerLastBlockSynced
        NotificationCenter.default.addObserver(self, selector: #selector(didFinishSyncing(_:)), name: lastName, object: nil)
    }
    
    private func findRate(_ rates: [Rate], for currency: Currency) throws -> Rate {
        guard let rate = rates.first(where: { $0.currencyCode == currency.code.uppercased() }) else {
            throw RateProviderError.currencyNotFound
        }
        return rate
    }
    
    @objc private func didFinishSyncing(_ notification: Notification) {
        guard let timeStamp = notification.userInfo?["timestamp"] as? TimeInterval else {
            return
        }
        let timestamp = Int64(timeStamp + NSTimeIntervalSince1970)
        getCurrentRate(blockTimestamp: timestamp)
    }
    
    @objc private func didReceiveNewBlock(_ notification: Notification) {
        guard let timeStamp = notification.userInfo?["timestamp"] as? TimeInterval else {
            return
        }
        let timestamp = Int64(timeStamp + NSTimeIntervalSince1970)
        guard isContains(timestamp) else {
            return
        }
        rateQueue.addOperation(with: timestamp, completion: ratesHandler(timestamp: timestamp))
    }
    
    private func isContains(_ timestamp: Int64) -> Bool {
        let isContains = try? !storage.existingTimestamps().contains(timestamp)
        return isContains ?? false
    }
    
    private func ratesHandler(timestamp: Int64) -> (Result<[Rate]>) -> Void {
        return { result in
            switch result {
            case .success(let rates):
                do {
                    try self.saveRates(rates, forTimestamp: timestamp)
                    Logger.info("Rates for timestamp \(timestamp) added")
                } catch {
                    Logger.error("Rates call for timestamp \(timestamp) failed with: \(error.localizedDescription)")
                    self.rateQueue.addOperation(with: timestamp, completion: self.ratesHandler(timestamp: timestamp))
                }
            case .failure(let error):
                Logger.error("Rates call for timestamp \(timestamp) failed with: \(error.localizedDescription)")
                switch error {
                case RatesRequestError.ratesArrayEmpty, RatesRequestError.notFound:
                    self.getCurrentRate(blockTimestamp: timestamp)
                default:
                    self.rateQueue.addOperation(with: timestamp, completion: self.ratesHandler(timestamp: timestamp))
                }
            }
        }
    }
    
    func getCurrentRate(blockTimestamp: Int64) {
        let supportedRates: [String] = CurrencyFactory.allowedCurrenies().flatMap({ $0.code })
        api.getCurrenciesRate(supportedRates: supportedRates) { result in
            switch result {
            case .success(let rates):
                do {
                    try self.saveRates(rates, forTimestamp: blockTimestamp)
                } catch let error {
                    Logger.error("Rates update failed with: \(error.localizedDescription)")
                }
            case .failure(let error):
                Logger.warn("Main rates download failed with \(error.localizedDescription)")
                self.getCurrentRateFallback(blockTimestamp: blockTimestamp)
            }
        }
    }
    
    func getCurrentRateFallback(blockTimestamp: Int64) {
        let supportedRates: [String] = CurrencyFactory.allowedCurrenies().flatMap({ $0.code })
        api.getCurrenciesRateFallback(supportedRates: supportedRates) { result in
            switch result {
            case .success(let rates):
                do {
                    try self.saveRates(rates, forTimestamp: blockTimestamp)
                } catch let error {
                    Logger.error("Rates update failed with: \(error.localizedDescription)")
                }
            case .failure(let error):
                Logger.error("Rates fallback fetch failed with: \(error.localizedDescription)")
            }
        }
    }
    
    func saveRates(_ rates: [Rate], forTimestamp timestamp: Int64) throws {
        let rateHistory = RateHistory(blockTimestamp: timestamp, rates: rates)
        try self.storage.update(with: rateHistory)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .walletRatesChangedNotificationName,
                                            object: rateHistory)
        }
    }
}

enum RateProviderError: LocalizedError {
    case currencyNotFound
}
