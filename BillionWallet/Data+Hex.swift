//
//  Data+Hex.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

// MARK: VIP
extension Data {
    
    init(hex string: String) {
        self.init()
        let string = string.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\t", with: "")
        if string.count % 2 != 0 {
            return
        }
        let re = try! NSRegularExpression(pattern: "[0-9a-f]{2}", options: .caseInsensitive)
        re.enumerateMatches(in: string, range: NSMakeRange(0, string.utf16.count)) { match, flags, stop in
            let byteString = (string as NSString).substring(with: match!.range)
            guard let byte = UInt8(byteString, radix: 16) else { return }
            self.append(byte)
        }
    }
    
    var hex: String {
        return self.map { String(format: "%02hhx", $0) }.joined()
    }
}
