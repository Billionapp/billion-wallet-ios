//
//  PCKeyCache.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct PCKeyCache {
    var Ke: Data
    var Km: Data
    var config: ECIESConfig
}

extension PCKeyCache {
    init?(_ ecies: ECIES) {
        guard ecies.Ke != nil &&
            ecies.Km != nil else {
                return nil
        }
        self.init(Ke: ecies.Ke!, Km: ecies.Km!, config: ecies.config)
    }
}

extension ECIES {
    convenience init(_ cache: PCKeyCache) {
        self.init(ke: cache.Ke, km: cache.Km, config: cache.config)
    }
}
