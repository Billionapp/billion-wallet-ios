//
//  BIP47Tests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
import CryptoSwift
@testable import BillionWallet

class BIP47Tests: XCTestCase {
    // BIP47 Test vectors from Samourai wallet
    // https://gist.github.com/SamouraiDev/6aad669604c5930864bd
    
    // MARK: Given constants
    let aliceBIP39Mnemonic = "response seminar brave tip suit recall often sound stick owner lottery motion"
    let bobBIP39Mnemonic = "reward upper indicate eight swift arch injury crystal super wrestle already dentist"
    let alicePrivateInput = "Kx983SRhAZpAhj7Aac1wUXMJ6XZeyJKqCxJJ49dxEbYCT4a1ozRD"
    let aliceOutpoint = "86f411ab1c8e70ae8a0795ab7a6757aea6e4d5ae1826fc7b8f00c597d500609c01000000"
    
    // MARK: Then constants
    let _aliceSeedHex = "64dca76abc9c6f0cf3d212d248c380c4622c8f93b2c425ec6a5567fd5db57e10d3e6f94a2f6af4ac2edb8998072aad92098db73558c323777abf5bd1082d970a"
    let _bobSeedHex = "87eaaac5a539ab028df44d9110defbef3797ddb805ca309f61a69ff96dbaa7ab5b24038cf029edec5235d933110f0aea8aeecf939ed14fc20730bba71e4b1110"
    let _alicePCHex = "02b85034fb08a8bfefd22848238257b252721454bbbfba2c3667f168837ea2cdad671af9f65904632e2dcc0c6ad314e11d53fc82fa4c4ea27a4a14eccecc478fee"
    let _bobPCHex = "029d125e1cb89e5a1a108192643ee25370c2e75c192b10aac18de8d5a09b5f48d51db1243aaa57c7fbea3072249c1bd4dab9482b4fee4d25e1c69707e8144dc137"
    let _alicePCStr = "PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA"
    let _alicePCStrTest = "SBRDJFwB8A4AMinNJZfnmLbN5QbPogCwGHKB5FQb4tfL7MC1eNcWJMSdmmW9KpgMFjfZN7zdM1d5tmHMbkAeFYnDo54gd9Z8YKovTnNTw4btdft3fNGU"
    let _bobPCStr = "PM8TJS2JxQ5ztXUpBBRnpTbcUXbUHy2T1abfrb3KkAAtMEGNbey4oumH7Hc578WgQJhPjBxteQ5GHHToTYHE3A1w6p7tU6KSoFmWBVbFGjKPisZDbP97"
    
    // Alice private key
    let _a = ["8d6a8ecd8ee5e0042ad0cb56e3a971c760b5145c3917a8e7beaf0ed92d7a520c"]
    // Alice public key
    let _A = ["0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683"]
    // Bob private keys
    let _b = [
        "04448fd1be0c9c13a5ca0b530e464b619dc091b299b98c5cab9978b32b4a1b8b",
        "6bfa917e4c44349bfdf46346d389bf73a18cec6bc544ce9f337e14721f06107b",
        "46d32fbee043d8ee176fe85a18da92557ee00b189b533fce2340e4745c4b7b8c",
        "4d3037cfd9479a082d3d56605c71cbf8f38dc088ba9f7a353951317c35e6c343",
        "97b94a9d173044b23b32f5ab64d905264622ecd3eafbe74ef986b45ff273bbba",
        "ce67e97abf4772d88385e66d9bf530ee66e07172d40219c62ee721ff1a0dca01",
        "ef049794ed2eef833d5466b3be6fe7676512aa302afcde0f88d6fcfe8c32cc09",
        "d3ea8f780bed7ef2cd0e38c5d943639663236247c0a77c2c16d374e5a202455b",
        "efb86ca2a3bad69558c2f7c2a1e2d7008bf7511acad5c2cbf909b851eb77e8f3",
        "18bcf19b0b4148e59e2bba63414d7a8ead135a7c2f500ae7811125fb6f7ce941"
    ]
    // Bob public keys
    let _B = [
        "024ce8e3b04ea205ff49f529950616c3db615b1e37753858cc60c1ce64d17e2ad8",
        "03e092e58581cf950ff9c8fc64395471733e13f97dedac0044ebd7d60ccc1eea4d",
        "029b5f290ef2f98a0462ec691f5cc3ae939325f7577fcaf06cfc3b8fc249402156",
        "02094be7e0eef614056dd7c8958ffa7c6628c1dab6706f2f9f45b5cbd14811de44",
        "031054b95b9bc5d2a62a79a58ecfe3af000595963ddc419c26dab75ee62e613842",
        "03dac6d8f74cacc7630106a1cfd68026c095d3d572f3ea088d9a078958f8593572",
        "02396351f38e5e46d9a270ad8ee221f250eb35a575e98805e94d11f45d763c4651",
        "039d46e873827767565141574aecde8fb3b0b4250db9668c73ac742f8b72bca0d0",
        "038921acc0665fd4717eb87f81404b96f8cba66761c847ebea086703a6ae7b05bd",
        "03d51a06c6b48f067ff144d5acdfbe046efa2e83515012cf4990a89341c1440289"
    ]
    // Shared secrets
    let _S = [
        "f5bb84706ee366052471e6139e6a9a969d586e5fe6471a9b96c3d8caefe86fef",
        "adfb9b18ee1c4460852806a8780802096d67a8c1766222598dc801076beb0b4d",
        "79e860c3eb885723bb5a1d54e5cecb7df5dc33b1d56802906762622fa3c18ee5",
        "d8339a01189872988ed4bd5954518485edebf52762bf698b75800ac38e32816d",
        "14c687bc1a01eb31e867e529fee73dd7540c51b9ff98f763adf1fc2f43f98e83",
        "725a8e3e4f74a50ee901af6444fb035cb8841e0f022da2201b65bc138c6066a2",
        "521bf140ed6fb5f1493a5164aafbd36d8a9e67696e7feb306611634f53aa9d1f",
        "5f5ecc738095a6fb1ea47acda4996f1206d3b30448f233ef6ed27baf77e81e46",
        "1e794128ac4c9837d7c3696bbc169a8ace40567dc262974206fcf581d56defb4",
        "fe36c27c62c99605d6cd7b63bf8d9fe85d753592b14744efca8be20a4d767c37"
    ]
    // Alice to Bob ethemeral addresses
    let _AB = [
        "141fi7TY3h936vRUKh1qfUZr8rSBuYbVBK",
        "12u3Uued2fuko2nY4SoSFGCoGLCBUGPkk6",
        "1FsBVhT5dQutGwaPePTYMe5qvYqqjxyftc",
        "1CZAmrbKL6fJ7wUxb99aETwXhcGeG3CpeA",
        "1KQvRShk6NqPfpr4Ehd53XUhpemBXtJPTL",
        "1KsLV2F47JAe6f8RtwzfqhjVa8mZEnTM7t",
        "1DdK9TknVwvBrJe7urqFmaxEtGF2TMWxzD",
        "16DpovNuhQJH7JUSZQFLBQgQYS4QB9Wy8e",
        "17qK2RPGZMDcci2BLQ6Ry2PDGJErrNojT5",
        "1GxfdfP286uE24qLZ9YRP3EWk2urqXgC4s"
    ]
    
    let _aliceNotificationAddress = "1JDdmqFLhpzcUwPeinhJbUPw4Co3aWLyzW"
    let _bobNotificationAddress = "1ChvUUvht2hUQufHBXF8NgLhW8SwE2ecGV"
    
    let _alicePCBinarySerializedHex = "010002b85034fb08a8bfefd22848238257b252721454bbbfba2c3667f168837ea2cdad671af9f65904632e2dcc0c6ad314e11d53fc82fa4c4ea27a4a14eccecc478fee00000000000000000000000000"
    
    let _sharedSecret = "736a25d9250238ad64ed5da03450c6a3f4f8f4dcdf0b58d1ed69029d76ead48d"
    let _blindingMask = "be6e7a4256cac6f4d4ed4639b8c39c4cb8bece40010908e70d17ea9d77b4dc57f1da36f2d6641ccb37cf2b9f3146686462e0fa3161ae74f88c0afd4e307adbd5"
    let _aliceMaskedPCPayload = "010002063e4eb95e62791b06c50e1a3a942e1ecaaa9afbbeb324d16ae6821e091611fa96c0cf048f607fe51a0327f5e2528979311c78cb2de0d682c61e1180fc3d543b00000000000000000000000000"
    let _aliceToBobNotificationTransaction = "010000000186f411ab1c8e70ae8a0795ab7a6757aea6e4d5ae1826fc7b8f00c597d500609c010000006b483045022100ac8c6dbc482c79e86c18928a8b364923c774bfdbd852059f6b3778f2319b59a7022029d7cc5724e2f41ab1fcfc0ba5a0d4f57ca76f72f19530ba97c860c70a6bf0a801210272d83d8a1fa323feab1c085157a0791b46eba34afb8bfbfaeb3a3fcc3f2c9ad8ffffffff0210270000000000001976a9148066a8e7ee82e5c5b9b7dc1765038340dc5420a988ac1027000000000000536a4c50010002063e4eb95e62791b06c50e1a3a942e1ecaaa9afbbeb324d16ae6821e091611fa96c0cf048f607fe51a0327f5e2528979311c78cb2de0d682c61e1180fc3d543b0000000000000000000000000000000000"
    let _notificationTransactionHash = "9414f1681fb1255bd168a806254321a837008dd4480c02226063183deb100204"
    
    func testSeed() {
        let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil)
        let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
        
        XCTAssertNotNil(aliceSeed)
        XCTAssertNotNil(bobSeed)
        XCTAssert(aliceSeed?.toHexString() == _aliceSeedHex, "\(aliceSeed?.toHexString() ?? "nil") != \(_aliceSeedHex)")
        XCTAssert(bobSeed?.toHexString() == _bobSeedHex, "\(bobSeed?.toHexString() ?? "nil") != \(_bobSeedHex)")
    }
    
    func testBIP44PaymentCodeDerivation() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
            else {
                XCTFail("Cannot continue test, mnemonic wtf occured")
                return
        }
        
        let alicePCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: bobSeed)
        
        XCTAssertNotNil(alicePCData)
        XCTAssertNotNil(bobPCData)
        XCTAssertNotNil(alicePCPrivData)
        XCTAssertNotNil(bobPCPrivData)
        XCTAssert(alicePCData.toHexString() == _alicePCHex, "\(alicePCData.toHexString()) != \(_alicePCHex)")
        XCTAssert(bobPCData.toHexString() == _bobPCHex, "\(bobPCData.toHexString()) != \(_bobPCHex)")
    }
    
    func testBIP44KeysDerivation() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil) else {
                return
        }
        
        let alicePCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: bobSeed)
        
        let a0 = BIP44Sequence().privateKey(0, forPaymentCodePriv: alicePCPrivData)
        let A0 = BIP44Sequence().publicKey(0, forPaymentCodePub: alicePCData)
        
        XCTAssert(a0.toHexString() == _a[0], "Alice 0 private: \(a0.toHexString()) != \(_a[0])")
        XCTAssert(A0.toHexString() == _A[0], "Alice 0 public: \(A0.toHexString()) != \(_A[0])")
        
        for i in 0..<_b.count {
            let bi = BIP44Sequence().privateKey(UInt32(i), forPaymentCodePriv: bobPCPrivData)
            XCTAssert(bi.toHexString() == _b[i], "Bob \(i) private: \(bi.toHexString()) != \(_b[0])")
        }
        
        for i in 0..<_B.count {
            let Bi = BIP44Sequence().publicKey(UInt32(i), forPaymentCodePub: bobPCData)
            XCTAssert(Bi.toHexString() == _B[i], "Bob \(i) public: \(Bi.toHexString()) != \(_B[0])")
        }
        
        for i in 0..<100 {
            let ai = BIP44Sequence().privateKey(UInt32(i), forPaymentCodePriv: alicePCPrivData)
            let Ai = BIP44Sequence().publicKey(UInt32(i), forPaymentCodePub: alicePCData)
            
            let aiPriv = Priv(data: ai)
            let AiPub = ECPointS( Secp256k1.pointGen(aiPriv.uint256) )
            let AiPubData = AiPub.data
            
            XCTAssert(AiPubData.toHexString() == Ai.toHexString(), "Alice \(i) generated keys don't match: \(AiPubData.toHexString()) != \(Ai.toHexString())")
        }
    }
    
    func testPaymentCodes() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
            else {
                XCTFail("Cannot continue test, some data is nil")
                return
        }
        
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        
        let alicePC = PrivatePaymentCode(priv: alicePCPrivData)
        guard let bobPC = try? PaymentCode(pub: bobPCData) else {
            XCTFail("Bob PC initialization failed")
            return
        }
        
        XCTAssert(alicePC.isInternal)
        XCTAssert(!bobPC.isInternal)
        
        let alicePCStr = alicePC.serializedString
        let bobPCStr = bobPC.serializedString
        let alicePCPayload = alicePC.binaryForm.toHexString()
        
        XCTAssert(alicePCStr == _alicePCStr, "\(alicePCStr) != \(_alicePCStr)")
        XCTAssert(alicePCPayload == _alicePCBinarySerializedHex, "\(alicePCPayload) != \(_alicePCBinarySerializedHex)")
        XCTAssert(bobPCStr == _bobPCStr, "\(bobPCStr) != \(_bobPCStr)")
        
        let aliceNotAddress = alicePC.notificationAddress
        let bobNotAddress = bobPC.notificationAddress
        
        XCTAssertNotNil(aliceNotAddress)
        XCTAssertNotNil(bobNotAddress)
        XCTAssert(aliceNotAddress == _aliceNotificationAddress, "\(aliceNotAddress ?? "nil") != \(_aliceNotificationAddress)")
        XCTAssert(bobNotAddress == _bobNotificationAddress, "\(bobNotAddress ?? "nil") != \(_bobNotificationAddress)")
    }
    
    func testSharedSecrets() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
            else {
                XCTFail("Cannot continue test, some data is nil")
                return
        }
        
        let alicePCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: aliceSeed)
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        let bobPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: bobSeed)
        
        // Alice computes shared secrets
        let alicePCInternal = PrivatePaymentCode(priv: alicePCPrivData)
        let a0 = alicePCInternal.notificationPrivateKey
        for i in 0..<_B.count {
            let BiData = BIP44Sequence().publicKey(UInt32(i), forPaymentCodePub: bobPCData)
            let Bi = Pub(data: BiData)
            let Si = BIP47.secretPoint(priv: a0, pub: Bi)
            let Six = BIP47.xFromPub(Si)
            
            let ss = Six.data.toHexString()
            XCTAssert(ss == _S[i], "Shared secret (Alice computed) \(i): \(ss) != \(_S[i])")
        }
        
        // Bob computes shared secrets
        guard let alicePC = try? PaymentCode(pub: alicePCData) else {
            XCTFail("Alice PC initialization failed")
            return
        }
        let A0 = alicePC.notificationKey
        for i in 0..<_b.count {
            let biData = BIP44Sequence().privateKey(UInt32(i), forPaymentCodePriv: bobPCPrivData)
            let bi = Priv(data: biData)
            let Si = BIP47.secretPoint(priv: bi, pub: A0)
            let Six = BIP47.xFromPub(Si)
            
            let ss = Six.data.toHexString()
            XCTAssert(ss == _S[i], "Shared secret (Bob computed) \(i): \(ss) != \(_S[i])")
        }
    }
    
    func testEthemeralAddressGeneration() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
            else {
                XCTFail("Cannot continue test, some data is nil")
                return
        }
        
        let alicePCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: aliceSeed)
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        let bobPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: bobSeed)
        
        // Alice computes send addresses Alice->Bob
        let alicePCInternal = PrivatePaymentCode(priv: alicePCPrivData)
        guard let bobPC = try? PaymentCode(pub: bobPCData) else {
            XCTFail("Bob PC initialization failed")
            return
        }
        for i in 0..<_AB.count {
            let key = alicePCInternal.ethemeralSendBRKey(to: bobPC, i: UInt32(i))
            
            XCTAssertNotNil(key)
            XCTAssert(key?.address == _AB[i], "Send address (Alice computed) \(i): \(key?.address ?? "nil") != \(_AB[i])")
        }
        
        // Bob computes receive addresses Alice->Bob
        guard let alicePC = try? PaymentCode(pub: alicePCData) else {
            XCTFail("Alice PC initialization failed")
            return
        }
        
        let bobPCInternal = PrivatePaymentCode(priv: bobPCPrivData)
        for i in 0..<_AB.count {
            let key = bobPCInternal.ethemeralReceiveBRKey(from: alicePC, i: UInt32(i))
            
            XCTAssertNotNil(key)
            XCTAssert(key?.address == _AB[i], "Receive address (Bob computed) \(i): \(key?.address ?? "nil") != \(_AB[i])")
        }
    }
    
    func testNotificationPayload() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
            else {
                XCTFail("Cannot continue test, some data is nil")
                return
        }
        
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        let bobPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: bobSeed)
        
        let alicePC = PrivatePaymentCode(priv: alicePCPrivData)
        guard let bobPC = try? PaymentCode(pub: bobPCData) else {
            XCTFail("Bob PC initialization failed")
            return
        }
        let bobPCPriv = PrivatePaymentCode(priv: bobPCPrivData)
        
        XCTAssert(alicePC.isInternal)
        XCTAssert(!bobPC.isInternal)
        
        guard let aliceK = BRKey(privateKey: alicePrivateInput) else {
            XCTFail("Cannot continue, alice PK is invalid")
            return
        }
        
        let aliceInput = Priv(aliceK.secretKey!.pointee)
        let outpoint = TXOutpointS(data: Data([UInt8](hex: aliceOutpoint)))
        
        XCTAssert(outpoint.data.toHexString() == aliceOutpoint)
        
        let payload = alicePC.notificationPayload(for: bobPC, outpoint: outpoint, key: aliceInput)
        XCTAssertNotNil(payload)
        XCTAssert(payload.toHexString() == _aliceMaskedPCPayload, "\(payload.toHexString()) != \(_aliceMaskedPCPayload)")
        
        let c = bobPCPriv.unmaskPaymentCode(payload, oupoint: outpoint, key: Pub(data: aliceK.publicKey!))
        XCTAssertNotNil(c)
        XCTAssert(c.serializedString == alicePC.serializedString, "\(c.serializedString) != \(alicePC.serializedString)")
    }
    
    func testNotificationTransaction() {
        guard let aliceSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: aliceBIP39Mnemonic, withPassphrase: nil),
            let bobSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: bobBIP39Mnemonic, withPassphrase: nil)
            else {
                XCTFail("Cannot continue test, some data is nil")
                return
        }
        
        let alicePCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: aliceSeed)
        let bobPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: bobSeed)
        let bobPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: bobSeed)
        
        let alicePC = PrivatePaymentCode(priv: alicePCPrivData)
        guard let bobPC = try? PaymentCode(pub: bobPCData) else {
            XCTFail("Bob PC initialization failed")
            return
        }
        let bobPCPriv = PrivatePaymentCode(priv: bobPCPrivData)
        
        XCTAssert(alicePC.isInternal)
        XCTAssert(!bobPC.isInternal)
        
        guard let aliceK = BRKey(privateKey: alicePrivateInput) else {
            XCTFail("Cannot continue, alice key is invalid")
            return
        }
        
        let aliceInput = Priv(aliceK.secretKey!.pointee)
        let outpoint = TXOutpointS(data: Data([UInt8](hex: aliceOutpoint)))
        
        XCTAssert(outpoint.data.toHexString() == aliceOutpoint)
        
        let tx = BRTransaction()
        let scriptSigHex = "483045022100ac8c6dbc482c79e86c18928a8b364923c774bfdbd852059f6b3778f2319b59a7022029d7cc5724e2f41ab1fcfc0ba5a0d4f57ca76f72f19530ba97c860c70a6bf0a801210272d83d8a1fa323feab1c085157a0791b46eba34afb8bfbfaeb3a3fcc3f2c9ad8"
        let scriptSig = Data([UInt8](hex: scriptSigHex))
        tx.addInputHash(outpoint.txId.uint256, index: UInt(outpoint.index), script: nil, signature: scriptSig, sequence: UINT32_MAX)
        tx.addOutputAddress(bobPC.notificationAddress!, amount: 10000)
        tx.addOutputScript(alicePC.notificationOpReturnScript(for: bobPC, outpoint: outpoint, key: aliceInput), amount: 10000)
        XCTAssert(tx.data.toHexString() == _aliceToBobNotificationTransaction, "\(tx.data.toHexString()) != \(_aliceToBobNotificationTransaction)")
        let hashStr = Data(tx.data.sha256().sha256().reversed()).toHexString()
        XCTAssert(hashStr == _notificationTransactionHash, "\(hashStr) != \(_notificationTransactionHash)")
        
        let txData = Data([UInt8](hex: _aliceToBobNotificationTransaction))
        let tx2 = BRTransaction(message: txData)
        let alicePCRecovered = bobPCPriv.recoverCode(from: tx2!)
        
        XCTAssert(alicePCRecovered?.serializedString == alicePC.serializedString, "\(alicePCRecovered?.serializedString ?? "nil") != \(alicePC.serializedString)")
    }
    
    func testOtherNetworks() {
        let data = Data(_alicePCHex.unHexed)
        let pcMain = try! PaymentCode(pub: data)
        let pcTest = try! PaymentCode(pub: data)
        pcMain.networkPrefix = .main
        pcTest.networkPrefix = .test
        
        XCTAssert(pcMain.serializedString == _alicePCStr, "Payment code string serialization (main) mismatch \(pcMain.serializedString) != \(_alicePCStr)")
        XCTAssert(pcTest.serializedString == _alicePCStrTest, "Payment code string serialization (test) mismatch \(pcTest.serializedString) != \(_alicePCStrTest)")
        XCTAssert(pcMain.serializedString.characters.first! != pcTest.serializedString.characters.first!, "First characters of mainnet and testnet serializations don't look different. Not cool.")
    }
}
