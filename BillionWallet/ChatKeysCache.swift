//
//  ChatKeysCache.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct ChatKeysCache {
    var version: Int = 0x01
    var selfPCData: Data?
    var otherPCData: Data?
    var selfIndex: UInt32 = 0x00
    var otherIndex: UInt32 = 0x00
    var Ke: Data?
    var Km: Data?
    var configProvider: ECIESConfigProvider {
        switch version {
        case 0x01:
            return Crypto()
        default:
            return LocalCrypto()
        }
    }
    var ecies: ECIES? {
        get {
            guard let Ke = Ke, let Km = Km else { return nil }
            return ECIES(ke: Ke, km: Km, config: configProvider.genECIESConfig())
        }
        set(value) {
            if let Ke = value?.Ke, let Km = value?.Km {
                self.Ke = Ke
                self.Km = Km
            }
        }
    }
    var isFilled: Bool {
        return selfPCData != nil &&
            otherPCData != nil &&
            Ke != nil &&
            Km != nil
    }
}
