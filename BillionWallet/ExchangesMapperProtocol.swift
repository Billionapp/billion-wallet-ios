//
//  ExchangesMapperProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol ExchangesMapperProtocol {
    func map(_ json: JSON) -> [String: Rates]
}
