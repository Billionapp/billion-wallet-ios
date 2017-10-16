//
//  ECIESConfigProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// ECIESConfig generator protocol
protocol ECIESConfigProvider {
    func genECIESConfig() -> ECIESConfig
    func genECIESConfig(_ salt1: Data?, _ salt2: Data?) -> ECIESConfig
}

extension ECIESConfigProvider {
    func genECIESConfig(_ salt1: Data? = nil, _ salt2: Data? = nil) -> ECIESConfig {
        var config = genECIESConfig()
        if let salt1 = salt1 {
            config.S1 = salt1
        }
        if let salt2 = salt2 {
            config.S2 = salt2
        }
        return config
    }
}
