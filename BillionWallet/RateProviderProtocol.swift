//
//  RateProviderProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol RateProviderProtocol {
    func getRate(for currency: Currency) throws -> Rate
    func getRate(for currency: Currency, timestamp: TimeInterval) throws -> Rate
}
