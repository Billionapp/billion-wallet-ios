//
//  PKCS7Padding.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension LocalCrypto {
    /// Padding PKCS#7
    struct PKCS7Padding {
        static func extend(_ message: Data, forBlockSize blockSize: Int) -> Data? {
            var paddingCount = blockSize - (message.count % blockSize)
            
            // If the original data is a multiple of N bytes, then an extra block of bytes with value N is added.
            if paddingCount == 0 {
                paddingCount = blockSize
            }
            let padding = Data(repeating: UInt8(paddingCount), count: paddingCount)
            guard let withPadding = NSMutableData(capacity: message.count + paddingCount) else {
                return nil
            }
            
            withPadding.append(message)
            withPadding.append(padding)
            return withPadding as Data
        }
        
        static func remove(for message: Data, withBlockSize blockSize: Int) -> Data? {
            let bytes = [UInt8](message)
            guard let lastByte = bytes.last else { return nil }
            // WARNING! Padding oracle attack is real.
            guard  lastByte > 0
                && lastByte <= UInt8(blockSize) else {
                    return nil // Invalid padding
            }
            
            let messageLength = bytes.count - Int(lastByte)
            guard messageLength >= 0 else { return nil }
            
            let messageBytes = [UInt8](bytes[0..<messageLength])
            return Data(messageBytes)
        }
    }
}
