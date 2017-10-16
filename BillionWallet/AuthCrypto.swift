//
//  AuthEncryption.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import CryptoSwift

class AuthCrypto {
    // HMAC-SHA1 signature
    static func MAC1(message: Data, key: Data) -> Data {
        let hmac = CryptoSwift.HMAC(key: key.bytes, variant: CryptoSwift.HMAC.Variant.sha1)
        let mac = try! hmac.authenticate(message.bytes)
        return Data(mac)
    }
}
