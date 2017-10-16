//
//  AuthManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CryptoSwift

class AuthManager {

    func getAuthHeader(for request: NetworkRequest) -> [String: String]? {
        
        guard let udid = AccountManager.shared.currentUdid else {
            return nil
        }
        
        var jsonString: String?
        if let body = request.body, let jsonData = try? JSONSerialization.data(withJSONObject: body) {
            jsonString = String(data: jsonData, encoding: .utf8)
        }
        jsonString = jsonString?.replacingOccurrences(of: "\\/", with: "/")
        
        guard let sharedKey = AccountManager.shared.sharedPubKey else {
            return nil
        }
        
        let nonce = Crypto.Random.data(4).hex
        let timestamp = "\(Int(Date().timeIntervalSince1970))"
        let contentType = request.headers?["Content-Type"]
        let message = Helper.generateMessageForAuthentification(contentType: contentType, method: request.method.rawValue, host: "devapi.digitalheroes.tech", uri: request.path, body: jsonString ?? "", udid: udid, timestamp: timestamp, nonce: nonce)
        let dataMessage = message.data(using: .utf8)
        let hmacBase64 = AuthCrypto.MAC1(message: dataMessage!, key: sharedKey).base64EncodedString()
        
        var headers =  [
            "X-Auth-Timestamp"  : timestamp,
            "X-Nonce"  : nonce,
            "X-Auth" : "\(udid) \(hmacBase64)"
        ]
        
        if request.body != nil {
            headers["Content-Type"] = "application/json"
        }
        
        return headers
    }
    
    func getRegisterHeader(for request: NetworkRequest) -> [String: String]? {
        let accountProvider = AccountManager.shared
        let timestamp = Int(NSDate().timeIntervalSince1970)
        
        guard let message = Helper.generateMessageForRegistration(from: request.method.rawValue, path: request.path, body: request.body, timestamp: "\(timestamp)") else {
            return nil
        }
        
        let authIdPrivate = accountProvider.getMnemonicAuthIdPriv()
        let signData = accountProvider.sign(message: message, mnemonicAuthIdPriv: authIdPrivate!)
        let signBase64String = signData?.base64EncodedString()
        let authIdPubData = accountProvider.getAuthIdPub()!
        let authIdPub = authIdPubData.base64EncodedString()
        
        return [
            "Content-Type"      : "application/json",
            "X-Auth-Timestamp"  : "\(timestamp)",
            "X-Auth-Signature"  : signBase64String!,
            "X-Auth-Public-Key" : authIdPub
        ]
    }
    
}
