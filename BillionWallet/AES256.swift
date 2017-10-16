//
//  AES256.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension LocalCrypto {
    /// Rijndael algorithm
    struct aes256 {
        static let blockSize = 128/8
        
        static func encrypt(_ message: Data, key: Data) -> Data {
            var message = message
            
            let blockCount = message.count / blockSize + 1
            message = PKCS7Padding.extend(message, forBlockSize: blockSize)!
            let result = NSMutableData(capacity: blockCount*blockSize)!
            for k in 0..<blockCount {
                let lower = k*blockSize
                let upper = min((k+1)*blockSize, message.count)
                if lower == upper { break }
                let range = lower..<upper as Range<Int>
                let messageBlock = message.subdata(in: range)
                var encryptedBlock: Data
                encryptedBlock = encryptBlock(messageBlock, key: key)
                result.append(encryptedBlock)
            }
            return result as Data
        }
        
        static func decrypt(_ cypher: Data, key: Data) -> Data {
            let blockCount = cypher.count / blockSize + 1
            let result = NSMutableData(capacity: blockCount*blockSize)!
            for k in 0..<blockCount {
                let lower = k*blockSize
                let upper = min((k+1)*blockSize, cypher.count)
                if lower == upper { break }
                let range = lower..<upper as Range<Int>
                let cypherBlock = cypher.subdata(in: range)
                var decryptedBlock: Data
                decryptedBlock = decryptBlock(cypherBlock, key: key)
                result.append(decryptedBlock)
            }
            let message = PKCS7Padding.remove(for: result as Data, withBlockSize: blockSize)!
            return message
        }
        
        static let sbox: [UInt8] = [
            0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
            0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
            0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
            0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
            0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
            0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
            0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
            0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
            0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
            0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
            0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
            0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
            0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
            0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
            0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
            0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
            ]
        
        static let sboxi: [UInt8] = [
            0x52, 0x09, 0x6a, 0xd5, 0x30, 0x36, 0xa5, 0x38, 0xbf, 0x40, 0xa3, 0x9e, 0x81, 0xf3, 0xd7, 0xfb,
            0x7c, 0xe3, 0x39, 0x82, 0x9b, 0x2f, 0xff, 0x87, 0x34, 0x8e, 0x43, 0x44, 0xc4, 0xde, 0xe9, 0xcb,
            0x54, 0x7b, 0x94, 0x32, 0xa6, 0xc2, 0x23, 0x3d, 0xee, 0x4c, 0x95, 0x0b, 0x42, 0xfa, 0xc3, 0x4e,
            0x08, 0x2e, 0xa1, 0x66, 0x28, 0xd9, 0x24, 0xb2, 0x76, 0x5b, 0xa2, 0x49, 0x6d, 0x8b, 0xd1, 0x25,
            0x72, 0xf8, 0xf6, 0x64, 0x86, 0x68, 0x98, 0x16, 0xd4, 0xa4, 0x5c, 0xcc, 0x5d, 0x65, 0xb6, 0x92,
            0x6c, 0x70, 0x48, 0x50, 0xfd, 0xed, 0xb9, 0xda, 0x5e, 0x15, 0x46, 0x57, 0xa7, 0x8d, 0x9d, 0x84,
            0x90, 0xd8, 0xab, 0x00, 0x8c, 0xbc, 0xd3, 0x0a, 0xf7, 0xe4, 0x58, 0x05, 0xb8, 0xb3, 0x45, 0x06,
            0xd0, 0x2c, 0x1e, 0x8f, 0xca, 0x3f, 0x0f, 0x02, 0xc1, 0xaf, 0xbd, 0x03, 0x01, 0x13, 0x8a, 0x6b,
            0x3a, 0x91, 0x11, 0x41, 0x4f, 0x67, 0xdc, 0xea, 0x97, 0xf2, 0xcf, 0xce, 0xf0, 0xb4, 0xe6, 0x73,
            0x96, 0xac, 0x74, 0x22, 0xe7, 0xad, 0x35, 0x85, 0xe2, 0xf9, 0x37, 0xe8, 0x1c, 0x75, 0xdf, 0x6e,
            0x47, 0xf1, 0x1a, 0x71, 0x1d, 0x29, 0xc5, 0x89, 0x6f, 0xb7, 0x62, 0x0e, 0xaa, 0x18, 0xbe, 0x1b,
            0xfc, 0x56, 0x3e, 0x4b, 0xc6, 0xd2, 0x79, 0x20, 0x9a, 0xdb, 0xc0, 0xfe, 0x78, 0xcd, 0x5a, 0xf4,
            0x1f, 0xdd, 0xa8, 0x33, 0x88, 0x07, 0xc7, 0x31, 0xb1, 0x12, 0x10, 0x59, 0x27, 0x80, 0xec, 0x5f,
            0x60, 0x51, 0x7f, 0xa9, 0x19, 0xb5, 0x4a, 0x0d, 0x2d, 0xe5, 0x7a, 0x9f, 0x93, 0xc9, 0x9c, 0xef,
            0xa0, 0xe0, 0x3b, 0x4d, 0xae, 0x2a, 0xf5, 0xb0, 0xc8, 0xeb, 0xbb, 0x3c, 0x83, 0x53, 0x99, 0x61,
            0x17, 0x2b, 0x04, 0x7e, 0xba, 0x77, 0xd6, 0x26, 0xe1, 0x69, 0x14, 0x63, 0x55, 0x21, 0x0c, 0x7d
            ]
        
        @inline(__always) fileprivate static func xt(_ x: UInt8) -> UInt8 {
            return (((x) << 1) ^ ((((x) >> 7) & 1)*0x1b))
        }
        
        fileprivate static func encryptBlock(_ block: Data, key: Data) -> Data {
            var r: UInt8 = 1
            var a, b, c, d, e: UInt8
            
            var k = [UInt8](key)
            var x = [UInt8](block)
            
            for i in 0..<14 {
                for j in 0..<16 {
                    x[j] ^= k[j + (i & 1)*16] // add round key
                }
                
                for j in 0..<16 {
                    x[j] = sbox[Int(x[j])] // sub bytes
                }
                
                // shift rows
                a = x[1]; x[1] = x[5]; x[5] = x[9]; x[9] = x[13]; x[13] = a; a = x[10]; x[10] = x[2]; x[2] = a
                a = x[3]; x[3] = x[15]; x[15] = x[11]; x[11] = x[7]; x[7] = a; a = x[14]; x[14] = x[6]; x[6] = a
                
                if i < 13 {
                    // mix columns
                    for j in stride(from: 0, to: 16, by: 4) {
                        a = x[j]; b = x[j+1]; c = x[j+2]; d = x[j+3]; e = a ^ b ^ c ^ d
                        x[j] ^= e ^ xt(a ^ b); x[j+1] ^= e ^ xt(b ^ c); x[j+2] ^= e ^ xt(c ^ d); x[j+3] ^= e ^ xt(d ^ a)
                    }
                }
                
                if (i % 2) != 0 { // expand key
                    k[0] ^= sbox[Int(k[29])] ^ r; k[1] ^= sbox[Int(k[30])]; k[2] ^= sbox[Int(k[31])]; k[3] ^= sbox[Int(k[28])]; r = xt(r)
                    for j in stride(from: 4, to: 16, by: 4) {
                        k[j] ^= k[j-4]; k[j+1] ^= k[j-3]; k[j+2] ^= k[j-2]; k[j+3] ^= k[j-1]
                    }
                    k[16] ^= sbox[Int(k[12])]; k[17] ^= sbox[Int(k[13])]; k[18] ^= sbox[Int(k[14])]; k[19] ^= sbox[Int(k[15])]
                    for j in stride(from: 20, to: 32, by: 4) {
                        k[j] ^= k[j-4]; k[j+1] ^= k[j-3]; k[j+2] ^= k[j-2]; k[j+3] ^= k[j-1]
                    }
                }
            }
            
            for i in 0..<16 {
                x[i] ^= k[i] // final add round key
            }
            return Data(x)
        }
        
        fileprivate static func decryptBlock(_ block: Data, key: Data) -> Data {
            var r: UInt8 = 1
            var a, b, c, d, e, f, g, h: UInt8
            
            var k = [UInt8](key)
            var x = [UInt8](block)
            
            for _ in 0..<7 { // expand key
                k[0] ^= sbox[Int(k[29])] ^ r; k[1] ^= sbox[Int(k[30])]; k[2] ^= sbox[Int(k[31])]; k[3] ^= sbox[Int(k[28])]; r = xt(r);
                for j in stride(from: 4, to: 16, by: 4) {
                    k[j] ^= k[j-4]; k[j+1] ^= k[j-3]; k[j+2] ^= k[j-2]; k[j+3] ^= k[j-1]
                }
                k[16] ^= sbox[Int(k[12])]; k[17] ^= sbox[Int(k[13])]; k[18] ^= sbox[Int(k[14])]; k[19] ^= sbox[Int(k[15])];
                
                for j in stride(from: 20, to: 32, by: 4) {
                    k[j] ^= k[j-4]; k[j+1] ^= k[j-3]; k[j+2] ^= k[j-2]; k[j+3] ^= k[j-1];
                }
            }
                
            for i in 0..<14 {
                for j in 0..<16 {
                    x[j] ^= k[j + (i & 1)*16] // add round key
                }
                
                if i > 0 {
                    for j in stride(from: 0, to: 16, by: 4) { // unmix columns
                        a = x[j]; b = x[j+1]; c = x[j+2]; d = x[j+3]; e = a ^ b ^ c ^ d;
                        h = xt(e); f = e ^ xt(xt(h ^ a ^ c)); g = e ^ xt(xt(h ^ b ^ d));
                        x[j] ^= f ^ xt(a ^ b); x[j+1] ^= g ^ xt(b ^ c); x[j+2] ^= f ^ xt(c ^ d); x[j+3] ^= g ^ xt(d ^ a);
                    }
                }
                
                // unshift rows
                a = x[1]; x[1] = x[13]; x[13] = x[9]; x[9] = x[5]; x[5] = a; a = x[2]; x[2] = x[10]; x[10] = a;
                a = x[3]; x[3] = x[7]; x[7] = x[11]; x[11] = x[15]; x[15] = a; a = x[6]; x[6] = x[14]; x[14] = a;
                
                for j in 0..<16 {
                    x[j] = sboxi[Int(x[j])] // unsub bytes
                }
                
                if ((i % 2) == 0) { // unexpand key
                    for j in stride(from: 28, to: 16, by: -4) {
                        k[j] ^= k[j-4]; k[j+1] ^= k[j-3]; k[j+2] ^= k[j-2]; k[j+3] ^= k[j-1];
                    }
                    k[16] ^= sbox[Int(k[12])]; k[17] ^= sbox[Int(k[13])]; k[18] ^= sbox[Int(k[14])]; k[19] ^= sbox[Int(k[15])];
                    for j in stride(from: 12, to: 0, by: -4) {
                        k[j] ^= k[j-4]; k[j+1] ^= k[j-3]; k[j+2] ^= k[j-2]; k[j+3] ^= k[j-1];
                    }
                    
                    r = (r >> 1) ^ ((r & 1)*0x8d)
                    k[0] ^= sbox[Int(k[29])] ^ r; k[1] ^= sbox[Int(k[30])]; k[2] ^= sbox[Int(k[31])]; k[3] ^= sbox[Int(k[28])];
                }
            }
            
            for i in 0..<16 {
                x[i] ^= k[i] // final add round key
            }
            return Data(x)
        }
    }
}
