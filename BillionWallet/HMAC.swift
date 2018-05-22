//
//  HMAC.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

fileprivate extension Data {
    var rawBytes: UnsafeRawPointer {
        return self.withUnsafeBytes { UnsafeRawPointer($0) }
    }
}

extension LocalCrypto {
    /// HMAC signature. Bread C variant.
    struct hmac {
        private static func digest(_ message: Data, key: Data, hash fun: @escaping (@convention(c) (UnsafeMutableRawPointer, UnsafeRawPointer, Int) -> Void), digestSize: Int) -> Data {
            let md = UnsafeMutableRawPointer.allocate(bytes: digestSize, alignedTo: 1)
            let data = message.rawBytes
            let key_p = key.rawBytes
            HMAC(md, fun, digestSize, key_p, key.count, data, message.count)
            let hmac = Data(bytes: md, count: digestSize)
            md.deallocate(bytes: digestSize, alignedTo: 1)
            return hmac
        }
        
        static func sha256(_ message: Data, key: Data) throws -> Data {
            let digestSize = 256/8
            return digest(message, key: key, hash: SHA256, digestSize: digestSize)
        }
        
        static func sha512(_ message: Data, key: Data) throws -> Data {
            let digestSize = 512/8
            return digest(message, key: key, hash: SHA512, digestSize: digestSize)
        }
    }
}
