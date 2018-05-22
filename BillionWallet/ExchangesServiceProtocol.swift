//
//  ExchangesServiceProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ExchangesServiceProtocol {
    func getState() -> ExchangeState
    func getExchanges(completion: @escaping (Result<[Exchange]>) -> Void)
    func getExchangeRates(ids: [String], completion: @escaping (Result<[String: Rates]>) -> Void)
}
