//
//  DefaultRateSource.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class DefaultRateSource: RatesSource {
    
    private let rateProvider: RateProviderProtocol
    
    init(rateProvider: RateProviderProtocol) {
        self.rateProvider = rateProvider
    }
    
    func rateForCurrency(_ currency: Currency) -> Rate? {
        return try? rateProvider.getRate(for: currency)
    }

}
