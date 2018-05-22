//
//  RateProviderFactoryProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol RateProviderFactoryProtocol {
    func create() -> RateProviderProtocol
}
