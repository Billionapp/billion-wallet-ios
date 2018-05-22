//
//  curve25519.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

// MARK: - Curve25519
public class Curve25519 {
    
    // MARK: - Utility
    class Utility {
        
        static func randomBytes(_ count: Int) -> [UInt8] {
            var randomness: [UInt8] = []
            for _ in 0..<count {
                let rand = UInt8(arc4random_uniform(UInt32(UInt8.max) + 1))
                randomness.append(rand)
            }
            return randomness
        }
        
        static func f32to8(_ arr: [UInt32], bigEndian: Bool = false) -> [UInt8] {
            var uint8: [UInt8] = []
            for uint32 in arr {
                let b1 = UInt8((uint32 & 0xff000000) >> 24)
                let b2 = UInt8((uint32 & 0x00ff0000) >> 16)
                let b3 = UInt8((uint32 & 0x0000ff00) >> 8)
                let b4 = UInt8(uint32 & 0x000000ff)
                
                if bigEndian {
                    uint8.append(contentsOf: [b4, b3, b2, b1])
                } else {
                    uint8.append(contentsOf: [b1, b2, b3, b4])
                }
            }
            return uint8
        }
        
        static func f8to32(_ arr: [UInt8], bigEndian: Bool = false) -> [UInt32] {
            var uint32: [UInt32] = []
            for i in stride(from: 0, to: arr.count - arr.count % 4, by: 4) {
                var num: UInt32 = 0
                for j in i..<i+4 {
                    let shift = UInt32(bigEndian ? (j-i)*8 : (3-j+i)*8)
                    num |= UInt32(arr[j]) << shift
                }
                uint32.append(num)
            }
            return uint32
        }
        
        static func unpack_8(_ str: String) -> [UInt8] {
            var bytes: [UInt8] = []
            
            let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
            regex.enumerateMatches(in: str, options: [], range: NSMakeRange(0, str.count)) { match, flags, stop in
                let byteString = (str as NSString).substring(with: match!.range)
                let num = UInt8(byteString, radix: 16)!
                bytes.append(num)
            }
            
            return bytes
        }
    }
    
    private var zero: [UInt32] = [0,0,0,0, 0,0,0,0, 0,0]
    private var one: [UInt32]  = [1,0,0,0, 0,0,0,0, 0,0]
    private var nine: [UInt32] = [9,0,0,0, 0,0,0,0, 0,0]
    
    public func publicKey(_ secret: String) -> [UInt8] {
        return self.scalarmult(self.clamp(secret), self.nine)
    }
    
    public func publicKey(_ secret: [UInt8]) -> [UInt8] {
        return self.scalarmult(self.clamp(secret), self.nine)
    }
    
    public func publicKey(_ secret: Data) -> [UInt8] {
        return self.scalarmult(self.clamp(secret), self.nine)
    }
    
    public func sharedKey(_ secret: [UInt8], pubK: [UInt8]) -> [UInt8] {
        var w: [UInt32] = Utility.f8to32(pubK, bigEndian: true)
        var r: [UInt32] = [
            w[0]                          & 0x3ffffff // 26
        ]
        r.append(
            ((w[0] >> 26) | (w[1] <<  6)) & 0x1ffffff // 25 - 51
        )
        r.append(
            ((w[1] >> 19) | (w[2] << 13)) & 0x3ffffff // 26 - 77
        )
        r.append(
            ((w[2] >> 13) | (w[3] << 19)) & 0x1ffffff // 25 - 102
        )
        r.append(
            (w[3] >> 6)                   & 0x3ffffff // 26 - 128
        )
        r.append(
            w[4]                          & 0x1ffffff // 25 - 153
        )
        r.append(
            ((w[4] >> 25) | (w[5] <<  7)) & 0x3ffffff // 26 - 179
        )
        r.append(
            ((w[5] >> 19) | (w[6] << 13)) & 0x1ffffff // 25 - 204
        )
        r.append(
            ((w[6] >> 12) | (w[7] << 20)) & 0x3ffffff // 26 - 230
        )
        r.append(
            (w[7] >> 6)                   & 0x1ffffff // 25 - 255
        )
        return self.scalarmult(self.clamp(secret), r)
    }
    
    public func sharedKey(_ secret: Data, pubK: Data) -> [UInt8] {
        let secret = [UInt8](secret)
        let pubK = [UInt8](pubK)
        return self.sharedKey(secret, pubK: pubK)
    }
    
    public func sharedKey(_ secret: String, pubK: String) -> [UInt8] {
        let pubK = Utility.unpack_8(pubK)
        let secret = Utility.unpack_8(secret)
        return self.sharedKey(secret, pubK: pubK)
    }
    
    public func clamp(_ secret: String) -> [UInt8] {
        let e = Utility.unpack_8(secret) // 32 x UInt8
        return self.clamp(e)
    }
    
    public func clamp(_ secret: Data) -> [UInt8] {
        let e = [UInt8](secret)
        return self.clamp(e)
    }
    
    public func clamp(_ secret: [UInt8]) -> [UInt8] {
        var secret = secret
        secret[0]  &= 0xf8
        secret[31] &= 0x7f
        secret[31] |= 0x40
        return secret
    }
    
    private func add(_ a: [UInt32], _ b: [UInt32]) -> [UInt32] {
        return [
            a[0] + b[0], a[1] + b[1], a[2] + b[2], a[3] + b[3], a[4] + b[4],
            a[5] + b[5], a[6] + b[6], a[7] + b[7], a[8] + b[8], a[9] + b[9]
        ];
    }
    
    private func sub(_ a: [UInt32], _ b: [UInt32]) -> [UInt32] {
        let a64: [UInt64] = a.map { UInt64($0) }
        let b64: [UInt64] = b.map { UInt64($0) }
        var c: UInt64 = 0
        var r: [UInt64] = [UInt64](repeating: 0, count: 10)
        
        c = 0x7ffffda + a64[0] - b64[0]
        r[0] = c & 0x3ffffff
        
        c = 0x3fffffe + a64[1] - b64[1] + (c >> 26)
        r[1] = c & 0x1ffffff
        
        c = 0x7fffffe + a64[2] - b64[2] + (c >> 25)
        r[2] = c & 0x3ffffff
        
        c = 0x3fffffe + a64[3] - b64[3] + (c >> 26)
        r[3] = c & 0x1ffffff
        
        c = 0x7fffffe + a64[4] - b64[4] + (c >> 25)
        r[4] = c & 0x3ffffff
        
        c = 0x3fffffe + a64[5] - b64[5] + (c >> 26)
        r[5] = c & 0x1ffffff
        
        c = 0x7fffffe + a64[6] - b64[6] + (c >> 25)
        r[6] = c & 0x3ffffff
        
        c = 0x3fffffe + a64[7] - b64[7] + (c >> 26)
        r[7] = c & 0x1ffffff
        
        c = 0x7fffffe + a64[8] - b64[8] + (c >> 25)
        r[8] = c & 0x3ffffff
        
        c = 0x3fffffe + a64[9] - b64[9] + (c >> 26)
        r[9] = c & 0x1ffffff
        
        r[0] += 19 * (c >> 25);
        let r32 = r.map { UInt32($0) }
        return r32
    }
    
    private func mul(_ a: [UInt32], _ b: [UInt32]) -> [UInt32] {
        let a: [UInt64] = a.map { UInt64($0) }
        let b: [UInt64] = b.map { UInt64($0) }
        
        var c: UInt64 = 0
        var shift: UInt64 = 0
        var r: [UInt64] = [UInt64](repeating: 0, count: 10)
        
        c = (b[0] * a[0]) + (b[1] * 38 * a[9]) + (b[2] * 19 * a[8]) + (b[3] * 38 * a[7]) + (b[4] * 19 * a[6]) + (b[5] * 38 * a[5]) + (b[6] * 19 * a[4]) + (b[7] * 38  * a[3]) + (b[8] * 19 * a[2]) + (b[9] * 38 * a[1])
        r[0] = c & 0x3ffffff
        
        shift = c >> 26
        c = (b[0] * a[1]) + (b[1] * a[0]) + (b[2] * 19 * a[9]) + (b[3] * 19 * a[8]) + (b[4] * 19 * a[7]) + (b[5] * 19 * a[6]) + (b[6] * 19 * a[5]) + (b[7] * 19 * a[4]) + (b[8] * 19 * a[3]) + (b[9] * 19 * a[2])
        c += shift
        r[1] = c & 0x1ffffff
        
        shift = (c >> 25)
        c = (b[0] * a[2]) + (b[1] * 2 * a[1]) + (b[2] * a[0]) + (b[3] * 38 * a[9]) + (b[4] * 19 * a[8]) + (b[5] * 38 * a[7]) + (b[6] * 19 * a[6]) + (b[7] * 38 * a[5]) + (b[8] * 19 * a[4]) + (b[9] * 38 * a[3])
        c += shift
        r[2] = c & 0x3ffffff
        
        shift = c >> 26
        c = (b[0] * a[3]) + (b[1] * a[2]) + (b[2] * a[1]) + (b[3] * a[0]) + (b[4] * 19 * a[9]) + (b[5] * 19 * a[8]) + (b[6] * 19 * a[7]) + (b[7] * 19 * a[6]) + (b[8] * 19 * a[5]) + (b[9] * 19 * a[4])
        c += shift
        r[3] = c & 0x1ffffff
        
        shift = c >> 25
        c = (b[0] * a[4]) + (b[1] * 2 * a[3]) + (b[2] * a[2]) + (b[3] * 2 * a[1]) + (b[4] * a[0]) + (b[5] * 38 * a[9]) + (b[6] * 19 * a[8]) + (b[7] * 38 * a[7]) + (b[8] * 19 * a[6]) + (b[9] * 38 * a[5])
        c += shift
        r[4] = c & 0x3ffffff
        
        shift = c >> 26
        c = (b[0] * a[5]) + (b[1] * a[4]) + (b[2] * a[3]) + (b[3] * a[2]) + (b[4] * a[1]) + (b[5] * a[0]) + (b[6] * 19 * a[9]) + (b[7] * 19 * a[8]) + (b[8] * 19 * a[7]) + (b[9] * 19 * a[6])
        c += shift
        r[5] = c & 0x1ffffff
        
        shift = c >> 25
        c = (b[0] * a[6]) + (b[1] * 2 * a[5]) + (b[2] * a[4]) + (b[3] * 2 * a[3]) + (b[4] * a[2]) + (b[5] * 2 * a[1]) + (b[6] * a[0]) + (b[7] * 38 * a[9]) + (b[8] * 19 * a[8]) + (b[9] * 38 * a[7])
        c += shift
        r[6] = c & 0x3ffffff
        
        shift = c >> 26
        c = (b[0] * a[7]) + (b[1] * a[6]) + (b[2] * a[5]) + (b[3] * a[4]) + (b[4] * a[3]) + (b[5] * a[2]) + (b[6] * a[1]) + (b[7] * a[0]) + (b[8] * 19 * a[9]) + (b[9] * 19 * a[8])
        c += shift
        r[7] = c & 0x1ffffff
        
        shift = c >> 25
        c = (b[0] * a[8]) + (b[1] * 2 * a[7]) + (b[2] * a[6]) + (b[3] * 2 * a[5]) + (b[4] * a[4]) + (b[5] * 2 * a[3]) + (b[6] * a[2]) + (b[7] * 2 * a[1]) + (b[8]    * a[0]) + (b[9] * 38 * a[9])
        c += shift
        r[8] = c & 0x3ffffff
        
        shift = c >> 26
        c = (b[0] * a[9]) + (b[1] * a[8]) + (b[2] * a[7]) + (b[3] * a[6]) + (b[4] * a[5]) + (b[5] * a[4]) + (b[6] * a[3]) + (b[7] * a[2]) + (b[8] * a[1]) + (b[9] * a[0])
        c += shift
        r[9] = c & 0x1ffffff
        
        c = 19 * (c >> 25)
        r[0] += c & 0x3ffffff
        r[1] += (c >> 26)
        
        let r32 = r.map { UInt32($0) }
        return r32
    }
    
    private func sqr(_ a: [UInt32], _ n: UInt8 = 1) -> [UInt32] {
        var r: [UInt64] = a.map { UInt64($0) }
        var res: [UInt32] = [UInt32](repeating: 0, count: 10)
        var s: [UInt64] = [UInt64](repeating: 0, count: 10)
        
        for _ in 0..<n {
            
            s[0] = r[0] * r[0] + 38 * r[5] * r[5] + 38 * r[6] * r[4] + 76 * r[7] * r[3] + 38 * r[8] * r[2] + 76 * r[9] * r[1]
            s[1] = 2 * r[0] * r[1] + 38 * r[6] * r[5] + 38 * r[7] * r[4] + 38 * r[8] * r[3] + 38 * r[9] * r[2]
            s[2] = (2 * r[0] * r[2]) + (2 * r[1] * r[1]) + (r[6] * 19 * r[6]) + (r[7] * 38 * r[5] * 2) + (r[8] * 19 * r[4] * 2) + (r[9] * 38 * r[3] * 2)
            s[3] = (2 * r[0] * r[3]) + (2 * r[1] * r[2]) + (r[7] * 38 * r[6]) + (r[8] * 19 * r[5] * 2) + (r[9] * 38 * r[4])
            s[4] = (2 * r[0] * r[4]) + (4 * r[1] * r[3]) + (r[2] * r[2]) + (r[7] * 38 * r[7]) + (r[8] * 19 * r[6] * 2) + (r[9] * 38 * r[5] * 2)
            s[5] = (2 * r[0] * r[5]) + (r[1] * 2 * r[4]) + (r[2] * 2 * r[3]) + (r[8] * 19 * r[7] * 2) + (r[9] * 38 * r[6])
            s[6] = (2 * r[0] * r[6]) + (r[1] * 2 * r[5] * 2) + (r[2] * 2 * r[4]) + (r[3] * 2 * r[3]) + (r[8] * 19 * r[8]) + (r[9] * 38 * r[7] * 2)
            s[7] = (2 * r[0] * r[7]) + (r[1] * 2 * r[6]) + (r[2] * 2 * r[5]) + (r[3] * 2 * r[4]) + (r[9] * 38 * r[8])
            s[8] = (2 * r[0] * r[8]) + (r[1] * 2 * r[7] * 2) + (r[2] * 2 * r[6]) + (r[3] * 2 * r[5] * 2) + (r[4] * r[4]) + (r[9] * 38 * r[9])
            s[9] = (2 * r[0] * r[9]) + (r[1] * 2 * r[8]) + (r[2] * 2 * r[7]) + (r[3] * 2 * r[6]) + (r[4] * r[5] * 2)
            
            var c = s[0]
            r[0] = c & 0x3ffffff
            
            c = s[1] + (c >> 26)
            r[1] = c & 0x1ffffff
            
            c = s[2] + (c >> 25)
            r[2] = c & 0x3ffffff
            
            c = s[3] + (c >> 26)
            r[3] = c & 0x1ffffff
            
            c = s[4] + (c >> 25)
            r[4] = c & 0x3ffffff
            
            c = s[5] + (c >> 26)
            r[5] = c & 0x1ffffff
            
            c = s[6] + (c >> 25)
            r[6] = c & 0x3ffffff
            
            c = s[7] + (c >> 26)
            r[7] = c & 0x1ffffff
            
            c = s[8] + (c >> 25)
            r[8] = c & 0x3ffffff
            
            c = s[9] + (c >> 26)
            r[9] = c & 0x1ffffff
            
            c = 19 * (c >> 25)
            r[0] += c & 0x3ffffff
            r[1] += (c >> 26)
        }
        res = r.map { UInt32($0) }
        return res
    }
    
    private func mul121665(_ i: [UInt32]) -> [UInt32] {
        let i: [UInt64] = i.map { UInt64($0) }
        var c: UInt64 = 0
        var r: [UInt64] = [UInt64](repeating: 0, count: 10)
        c = i[0] * 121665
        r[0] = c & 0x3ffffff
        
        c = i[1] * 121665 + (c >> 26)
        r[1] = c & 0x1ffffff
        
        c = i[2] * 121665 + (c >> 25)
        r[2] = c & 0x3ffffff
        
        c = i[3] * 121665 + (c >> 26)
        r[3] = c & 0x1ffffff
        
        c = i[4] * 121665 + (c >> 25)
        r[4] = c & 0x3ffffff
        
        c = i[5] * 121665 + (c >> 26)
        r[5] = c & 0x1ffffff
        
        c = i[6] * 121665 + (c >> 25)
        r[6] = c & 0x3ffffff
        
        c = i[7] * 121665 + (c >> 26)
        r[7] = c & 0x1ffffff
        
        c = i[8] * 121665 + (c >> 25)
        r[8] = c & 0x3ffffff
        
        c = i[9] * 121665 + (c >> 26)
        r[9] = c & 0x1ffffff
        
        r[0] += 19 * (c >> 25)
        let res = r.map { UInt32($0) }
        return res
    }
    
    private func scalarmult(_ f: [UInt8], _ c: [UInt32]) -> [UInt8] {
        var t = self.one;
        var u = self.zero;
        var v = self.one;
        var y: [UInt32] = []
        var w = c;
        var x: [UInt32]
        var z: [UInt32]
        var swapBit: UInt8 = 1;
        var i: UInt8 = 253
        while i >= 2 {
            x = self.add(w, v);
            v = self.sub(w, v);
            y = self.add(t, u);
            u = self.sub(t, u);
            t = self.mul(y, v);
            u = self.mul(x, u);
            z = self.add(t, u);
            u = self.sqr(self.sub(t, u));
            t = self.sqr(z);
            u = self.mul(u, c);
            x = self.sqr(x);
            v = self.sqr(v);
            w = self.mul(x, v);
            v = self.sub(x, v);
            v = self.mul(v, self.add(self.mul121665(v), x));
            let b = (f[Int(i >> 3)] >> (i & 7)) & 1
            // Constant time (i.e. branchless) swap.
            var kk = [[w, t, v, u], [t, w, u, v]][Int(b ^ swapBit)];
            w = kk[0]
            t = kk[1]
            v = kk[2]
            u = kk[3]
            swapBit = b;
            i -= 1
        }
        for _ in 0..<3 {
            x = self.sqr(self.add(w, v));
            v = self.sqr(self.sub(w, v));
            w = self.mul(x, v);
            v = self.sub(x, v);
            v = self.mul(v, self.add(self.mul121665(v), x));
        }
        var a = self.sqr(v);
        var b = self.mul(self.sqr(a, 2), v);
        a = self.mul(b, a);
        b = self.mul(self.sqr(a), b);
        b = self.mul(self.sqr(b, 5), b);
        var c = self.mul(self.sqr(b, 10), b);
        b = self.mul(self.sqr(self.mul(self.sqr(c, 20), c), 10), b);
        c = self.mul(self.sqr(b, 50), b);
        var r = self.mul(w, self.mul(self.sqr(self.mul(self.sqr(self.mul(self.sqr(c, 100), c), 50), b), 5), a));
        var rr: [UInt32] = [0,0,0,0,0,0,0,0,0,0]
        
        var cc = r[0] + 0x4000000
        rr[0] = cc & 0x3ffffff
        
        cc = r[1] + 0x1ffffff + (cc >> 26)
        rr[1] = cc & 0x1ffffff
        
        cc = r[2] + 0x3ffffff + (cc >> 25)
        rr[2] = cc & 0x3ffffff
        
        cc = r[3] + 0x1ffffff + (cc >> 26)
        rr[3] = cc & 0x1ffffff
        
        cc = r[4] + 0x3ffffff + (cc >> 25)
        rr[4] = cc & 0x3ffffff
        
        cc = r[5] + 0x1ffffff + (cc >> 26)
        rr[5] = cc & 0x1ffffff
        
        cc = r[6] + 0x3ffffff + (cc >> 25)
        rr[6] = cc & 0x3ffffff
        
        cc = r[7] + 0x1ffffff + (cc >> 26)
        rr[7] = cc & 0x1ffffff
        
        cc = r[8] + 0x3ffffff + (cc >> 25)
        rr[8] = cc & 0x3ffffff
        
        cc = r[9] + 0x1ffffff + (cc >> 26)
        rr[9] = cc & 0x1ffffff
        
        var f32: [UInt32] = [
            rr[0] | (rr[1] << 26)
            ]
        f32.append(
            (rr[1] >> 6) | (rr[2] << 19)
        )
        f32.append(
            (rr[2] >> 13) | (rr[3] << 13)
        )
        f32.append(
            (rr[3] >> 19) | (rr[4] << 6)
        )
        f32.append(
            rr[5] | (rr[6] << 25)
        )
        f32.append(
            (rr[6] >> 7) | (rr[7] << 19)
        )
        f32.append(
            (rr[7] >> 13) | (rr[8] << 12)
        )
        f32.append(
            (rr[8] >> 20) | (rr[9] << 6)
        )
        return Utility.f32to8(f32,
                              bigEndian: true)
    }
}

// MARK: - String+Utility
extension String {
    var unHexed: [UInt8] {
        return Curve25519.Utility.unpack_8(self)
    }
}
