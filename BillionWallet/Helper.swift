//
//  Helper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/04/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import LocalAuthentication

class Helper {
    class func generateMessageForRegistration(from httpMethod: String, path: String, body: [String: Any]?, timestamp: String) -> String? {
        
        if let bodyDict = body {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: bodyDict), var jsonDataString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            
            jsonDataString = jsonDataString.replacingOccurrences(of: "\\/", with: "/")
            return "\(httpMethod)\(path)\(jsonDataString)\(timestamp)"
        }
        return nil
    }
    
    class func generateMessageForAuthentification(contentType: String?, method: String, host: String, uri: String, body: Data?, udid: String, timestamp: String, nonce: String) -> String {
        
        let contentType = contentType ?? (body == nil ? "" : "application/json")
        
        let bodySha1 = body?.sha1().hex ?? ""
        return [method, host, uri, contentType , bodySha1, udid, timestamp, nonce].joined(separator: "|")
    }
    
    class func abbreviateAmount(_ amt: Double) -> String {
        let k = NSLocalizedString("k", comment: "")
        let m = NSLocalizedString("m", comment: "")
        let bi = NSLocalizedString("bi", comment: "")
        let q = NSLocalizedString("q", comment: "")
        let number = amt
        let abbrev = [k, m, bi, q]
        var outputString = ""
        
        guard amt >= 1000 else {
            guard abs(amt) < 1 else {
                let isInteger = floor(amt) == amt
                if isInteger {
                    return "\(amt)"
                } else {
                    return String(format:"%.01f", amt)
                }
            }
            return "0"
        }
        
        for (i, abbr) in abbrev.enumerated().reversed() {
            let size = (pow(10, (i+1)*3) as NSDecimalNumber).doubleValue
            
            if size <= number {
                let shortNumber = number / size
                let shortString = String(format:"%.01f", shortNumber)
                outputString = "\(shortString)\(abbr)"
                break
            }
        }

        return outputString
    }
    
    static func delay(_ delay: Double, queue: DispatchQueue, closure: @escaping () -> ()) {
        let when = DispatchTime.now() + delay
        queue.asyncAfter(deadline: when, execute: closure)
    }
}
