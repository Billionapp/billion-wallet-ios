//
//  HistoricalRatesSource.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class HistoricalRatesSource: RatesSource {
    private let ratesProvider: RateProviderProtocol
    private var time: TimeInterval = Date().timeIntervalSince1970
    
    init(ratesProvider: RateProviderProtocol) {
        self.ratesProvider = ratesProvider
    }
    
    func set(time: TimeInterval) {
        self.time = time
    }
    
    func rateForCurrency(_ currency: Currency) -> Rate? {
        let rate = try? ratesProvider.getRate(for: currency, timestamp: time)
        let currentRate = try? ratesProvider.getRate(for: currency)
        return rate ?? currentRate
    }
}
