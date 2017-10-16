//
//  Extensions.swift
//  BreadWallet
//
//  Created by Samuel Sutch on 1/30/16.
//  Copyright (c) 2016 breadwallet LLC
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation


public extension String {
    func md5() -> String {
        let data = (self as NSString).data(using: String.Encoding.utf8.rawValue)!
        let result = NSMutableData(length: Int(128/8))!
        let resultBytes = result.mutableBytes
        MD5(resultBytes, (data as NSData).bytes, data.count)
        
//        let a = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result.length)
        let a = resultBytes.assumingMemoryBound(to: CUnsignedChar.self)
        let hash = NSMutableString()
        
        for i in 0..<result.length {
            hash.appendFormat("%02x", a[i])
        }
        
        return hash as String
    }
    
    func parseQueryString() -> [String: [String]] {
        var ret = [String: [String]]()
        var strippedString = self
        let toIndex = self.characters.index(self.startIndex, offsetBy: 1)
        if self[..<toIndex] == "?" {
            let fromIndex = self.characters.index(self.startIndex, offsetBy: 1)
            strippedString = String(self[fromIndex...])
        }
        strippedString = strippedString.replacingOccurrences(of: "+", with: " ")
        strippedString = strippedString.removingPercentEncoding!
        for s in strippedString.components(separatedBy: "&") {
            let kp = s.components(separatedBy: "=")
            if kp.count == 2 {
                if var k = ret[kp[0]] {
                    k.append(kp[1])
                } else {
                    ret[kp[0]] = [kp[1]]
                }
            }
        }
        return ret
    }
    
    static func buildQueryString(_ options: [String: [String]]?, includeQ: Bool = false) -> String {
        var s = ""
        if let options = options , options.count > 0 {
            s = includeQ ? "?" : ""
            var i = 0
            for (k, vals) in options {
                for v in vals {
                    if i != 0 {
                        s += "&"
                    }
                    i += 1
                    s += "\(k.urlEscapedString)=\(v.urlEscapedString)"
                }
            }
        }
        return s
    }
}

var BZCompressionBufferSize: UInt32 = 1024
var BZDefaultBlockSize: Int32 = 7
var BZDefaultWorkFactor: Int32 = 100

public extension Data {
    var hexString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
    
    var bzCompressedData: Data? {
        get {
            if self.count == 0 {
                return self
            }
            var compressed = [UInt8]()
            var stream = bz_stream()
            var mself = self
            var success = true
            mself.withUnsafeMutableBytes { (selfBuff: UnsafeMutablePointer<Int8>) -> Void in
                stream.next_in = selfBuff
                stream.avail_in = UInt32(self.count)
                var buff = Data(capacity: Int(BZCompressionBufferSize))
                buff.withUnsafeMutableBytes({ (outBuff: UnsafeMutablePointer<Int8>) -> Void in
                    stream.next_out = outBuff
                    stream.avail_out = BZCompressionBufferSize
                    var bzret = BZ2_bzCompressInit(&stream, BZDefaultBlockSize, 0, BZDefaultWorkFactor)
                    if bzret != BZ_OK {
                        print("failed compression init")
                        success = false
                        return
                    }
                    repeat {
                        bzret = BZ2_bzCompress(&stream, stream.avail_in > 0 ? BZ_RUN : BZ_FINISH)
                        if bzret < BZ_OK {
                            print("failed compress")
                            success = false
                            return
                        }
                        buff.withUnsafeBytes({ (bp: UnsafePointer<UInt8>) -> Void in
                            let bpp = UnsafeBufferPointer(
                                start: bp, count: (Int(BZCompressionBufferSize) - Int(stream.avail_out)))
                            compressed.append(contentsOf: bpp)
                        })
                        stream.next_out = outBuff
                        stream.avail_out = BZCompressionBufferSize
                    } while bzret != BZ_STREAM_END
                })
            }
            BZ2_bzCompressEnd(&stream)
            if !success {
                return nil
            }
            return Data(bytes: compressed)
        }
    }

    init?(bzCompressedData data: Data) {
        if data.count == 0 {
            return nil
        }
        var stream = bz_stream()
        var decompressed = [UInt8]()
        var myDat = data
        var success = true
        myDat.withUnsafeMutableBytes { (datBuff: UnsafeMutablePointer<Int8>) -> Void in
            stream.next_in = datBuff
            stream.avail_in = UInt32(data.count)
            var buff = Data(capacity: Int(BZCompressionBufferSize))
            buff.withUnsafeMutableBytes { (outBuff: UnsafeMutablePointer<Int8>) -> Void in
                stream.next_out = outBuff
                stream.avail_out = BZCompressionBufferSize
                var bzret = BZ2_bzDecompressInit(&stream, 0, 0)
                if bzret != BZ_OK {
                    print("failed decompress init")
                    success = false
                    return
                }
                repeat {
                    bzret = BZ2_bzDecompress(&stream)
                    if bzret < BZ_OK {
                        print("failed decompress")
                        success = false
                        return
                    }
                    buff.withUnsafeBytes({ (bp: UnsafePointer<UInt8>) -> Void in
                        let bpp = UnsafeBufferPointer(
                            start: bp, count: (Int(BZCompressionBufferSize) - Int(stream.avail_out)))
                        decompressed.append(contentsOf: bpp)
                    })
                    stream.next_out = outBuff
                    stream.avail_out = BZCompressionBufferSize
                } while bzret != BZ_STREAM_END
            }
        }
        BZ2_bzDecompressEnd(&stream)
        if !success {
            return nil
        }
        self.init(bytes: decompressed)
    }
}

public extension Date {
    static func withMsTimestamp(_ ms: UInt64) -> Date {
        return Date(timeIntervalSince1970: Double(ms) / 1000.0)
    }
    
    func msTimestamp() -> UInt64 {
        return UInt64((self.timeIntervalSince1970 < 0 ? 0 : self.timeIntervalSince1970) * 1000.0)
    }

    // this is lifted from: https://github.com/Fykec/NSDate-RFC1123/blob/master/NSDate%2BRFC1123.swift
    // Copyright © 2015 Foster Yin. All rights reserved.
    fileprivate static func cachedThreadLocalObjectWithKey<T: AnyObject>(_ key: String, create: () -> T) -> T {
        let threadDictionary = Thread.current.threadDictionary
        if let cachedObject = threadDictionary[key] as! T? {
            return cachedObject
        }
        else {
            let newObject = create()
            threadDictionary[key] = newObject
            return newObject
        }
    }
    
    fileprivate static func RFC1123DateFormatter() -> DateFormatter {
        return cachedThreadLocalObjectWithKey("RFC1123DateFormatter") {
            let locale = Locale(identifier: "en_US")
            let timeZone = TimeZone(identifier: "GMT")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale //need locale for some iOS 9 verision, will not select correct default locale
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
            return dateFormatter
        }
    }
    
    fileprivate static func RFC850DateFormatter() -> DateFormatter {
        return cachedThreadLocalObjectWithKey("RFC850DateFormatter") {
            let locale = Locale(identifier: "en_US")
            let timeZone = TimeZone(identifier: "GMT")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale //need locale for some iOS 9 verision, will not select correct default locale
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "EEEE, dd-MMM-yy HH:mm:ss z"
            return dateFormatter
        }
    }
    
    fileprivate static func asctimeDateFormatter() -> DateFormatter {
        return cachedThreadLocalObjectWithKey("asctimeDateFormatter") {
            let locale = Locale(identifier: "en_US")
            let timeZone = TimeZone(identifier: "GMT")
            let dateFormatter = DateFormatter()
            dateFormatter.locale = locale //need locale for some iOS 9 verision, will not select correct default locale
            dateFormatter.timeZone = timeZone
            dateFormatter.dateFormat = "EEE MMM d HH:mm:ss yyyy"
            return dateFormatter
        }
    }
    
    static func fromRFC1123(_ dateString: String) -> Date? {
        
        var date: Date?
        // RFC1123
        date = Date.RFC1123DateFormatter().date(from: dateString)
        if date != nil {
            return date
        }
        
        // RFC850
        date = Date.RFC850DateFormatter().date(from: dateString)
        if date != nil {
            return date
        }
        
        // asctime-date
        date = Date.asctimeDateFormatter().date(from: dateString)
        if date != nil {
            return date
        }
        return nil
    }
    
    func RFC1123String() -> String? {
        return Date.RFC1123DateFormatter().string(from: self)
    }
}

extension UIImage {
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameters:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
        
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = (newSize.height - size.height * aspectRatio) / 2.0
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(newSize)
        
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
}
