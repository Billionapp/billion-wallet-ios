//
//  RegisterGenTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class RegisterGenTests: XCTestCase {
    
    // given
    let _udid = "807ed845-38a0-4851-bed8-4538a0c8514b"
    let _ecdhPrivBase64 = "CIQcefsNwtQbEnFEvCa0kwvbPU1PCbJINb8E2X76THU="
    let _privateIdKeyBase64 = "6BJzWeO4/KBmbc8MwUJ57FodgA2NQ1dKhvkfodAtsdY="
    let _timestamp = "1505223961"
    let _httpMethod = "POST"
    let _path = "/register"
    let _signBase64 = "MEQCIEEm+OQ6ooldnEPQTVQJfoSPf0qHXg5ib2LCLU6jVj3mAiByXWZQpCTiPPjxSLyuCn5HTKTuU5MnPXMoi5Kn53LN6A=="
    let account = AccountManager.shared
    
    // then
    let _walletDigest = "1DvBTwm5ZFptW3NLrmDWiRNPU7ZvEyb2DK"
    let _pubKeyString = "ApZ+McGgOVbkeXKYdW2X4V/10ZeoxG1gw7AezwFQYCn8"
    let _ecdhPubString = "tmyKsoymi2nWHCjGJeot0KfB+Ab/J6y/712nviNB1XY="
    let _message = "POST/register{\"ecdh_public\":\"tmyKsoymi2nWHCjGJeot0KfB+Ab/J6y/712nviNB1XY=\",\"wallet_digest\":\"1DvBTwm5ZFptW3NLrmDWiRNPU7ZvEyb2DK\",\"udid\":\"807ed845-38a0-4851-bed8-4538a0c8514b\"}1505223961"
    let _messageDoubleSha256Hex = "13828187279858f46a0493cf914361fe5d47462be118f2488c55e7b4e08f8cad"
    
    var ecdhPrivate: Data!
    var privateIdKey: Data!
    
    override func setUp() {
        super.setUp()
        ecdhPrivate = Data(base64Encoded: _ecdhPrivBase64)
        privateIdKey = Data(base64Encoded: _privateIdKeyBase64)
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testExample() {
        let privKey = Priv(data: privateIdKey)
        
        let pubKeyGen = Secp256k1.pointGen(privKey.uint256)
        let pubKey = ECPointS(pubKeyGen)
        let walletDigest = Data(uint160: pubKey.data.hash160).base58CheckString(versionByte: 0x00)
        
        XCTAssert(walletDigest == _walletDigest, "Wallet digest don't match \(walletDigest) != \(_walletDigest)")
        
        let time = 1505223961
        let publicKeyString = pubKey.data.base64EncodedString()
        
        XCTAssert(publicKeyString == _pubKeyString, "Public key string doesn't match \(publicKeyString) != \(_pubKeyString)")
        
        let ecdhPublic = Data(Curve25519().publicKey(ecdhPrivate))
        let ecdhPubStr = ecdhPublic.base64EncodedString()
        
        XCTAssert(ecdhPubStr == _ecdhPubString, "ECDH Public string doesn't match \(ecdhPubStr) != \(_ecdhPubString)")
        
        var headers = [
            "X-Auth-Public-Key": publicKeyString,
            "X-Auth-Timestamp": "\(time)",
        ]
        let body = [
            "ecdh_public": ecdhPubStr,
            "wallet_digest": walletDigest,
            "udid": _udid,
            ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body),
            var jsonBody = String(data: jsonData, encoding: .utf8) else {
                XCTFail("Json body creation failed")
                return
        }
        
        jsonBody = jsonBody.replacingOccurrences(of: "\\/", with: "/")
        
        var message = "POST"
        message.append("/register")
        message.append(jsonBody)
        message.append(headers["X-Auth-Timestamp"]!)
        
        XCTAssert(message == _message, "Message doesn't match \(message) != \(_message)")
        
        guard let messageData = message.data(using: .utf8) else {
            XCTFail("Message data is not UTF8")
            return
        }
        let messageHash = messageData.sha256().sha256()
        
        XCTAssert(messageHash.hex == _messageDoubleSha256Hex, "Message double hash doesn't match \(messageHash.hex) != \(_messageDoubleSha256Hex)")
        
        let hashAsUInt256 = UInt256S(data: messageHash)
        
        guard let signature = Secp256k1.signData(hashAsUInt256.uint256, key: privKey.uint256) else {
            XCTFail("Signature creation failed")
            return
        }
        
        XCTAssert(signature[0] == 0x30, "Signature not DER encoded")
        
        headers["X-Auth-Signature"] = signature.base64EncodedString()
        
        let verification = Secp256k1.verifySignature(signature, forData: hashAsUInt256.uint256, withKey: pubKey.ecpoint)
        
        XCTAssert(verification, "Signature verification failed")
        
        //Uncomment to get specs for Postman
        //print(headers)
        //print(jsonBody)
    }
    
    func testSign() {
        guard let sign = account.sign(message: _message, mnemonicAuthIdPriv: privateIdKey) else {
            XCTFail("Signature creation failed")
            return
        }
        
        XCTAssert(sign[0] == 0x30, "Signature not DER encoded")
        
        let signBase64 = sign.base64EncodedString()
        XCTAssert(signBase64 == _signBase64, "Sign not matched \(signBase64) != \(_signBase64)")
    }
}
