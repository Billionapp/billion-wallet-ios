//
//  PaymentCodeEncryptionTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

fileprivate func calcTrash(data: Data) -> Double {
    let characters = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмопрстуфхцчшщъыьэюя .,!".data(using: .utf8)!
    var trashData = 0
    for d in data {
        if !characters.contains(d) {
            trashData += 1
        }
    }
    let trashPercent = Double(trashData)/Double(data.count)
    return trashPercent
}

fileprivate class FakeSecureDataStorage: SecureDataStorage {
    private var storage: [String: Data] = [:]
    
    func store(_ data: Data, forKey key: String) {
        self.storage[key] = data
    }
    
    func load(key: String) -> Data? {
        return self.storage[key]
    }
}

class PaymentCodeEncryptionTests: XCTestCase {
    
    let trashThreshold: Double = 0.56
    
    let _alicePCPrivHex = "0a5c1795378b3ba756efcb5ca47e605c3f4f8bcff99eced897b45a4b051e980d671af9f65904632e2dcc0c6ad314e11d53fc82fa4c4ea27a4a14eccecc478fee"
    let _bobPCPrivHex = "b7f3d1104fc72d8226b9d78ce9340aa8be76d979390c22cf491104775813a6421db1243aaa57c7fbea3072249c1bd4dab9482b4fee4d25e1c69707e8144dc137"
    
    var alicePC: PaymentCode!
    var bobPC: PaymentCode!
    var alicePCEncryptorBuilder: PCEncryptorBuilder!
    var bobPCEncryptorBuilder: PCEncryptorBuilder!
    var utf8texts: [String] = []
    
    override func setUp() {
        super.setUp()
        utf8texts = [
            "бля",
            "Оно увы тощ мой ран так Уже мню. Натягивают БЕССМЕРТИЕ процветают. Те Ни взирайте гармонию ИЗ До охранены на Нетленье нечестье Вы приносит. Ты от ИЗ со По им. Всем верх Сион СИЛУ Уста. Satoshi WuS h3r3. Нечестивы от ее восстанет Христовых Ея трепетала он Ливанских ах. Мы да Во ум же ад Тя ею. Презренным смертельно освещенных сокровенно",
            "Волшебное Искушения богатство. . Выходил трудись зовущий кротить любящих уясняся. Тму див шум увы Чей рек яры Вот. Во Ум Ея ее ея то До. Бытие Еще огнем как Оно Рек Душ сих гласа велел жирны Падши. Ком угодны Терпел нас Блюдут Случай чей Твоего ков ему дивный. Миг Чья сон ним Уже Быв дна сих.",
            "Позабыть Взыграет вселенну смиренну незлобье Божество. Красой долгим концов лесами Котору являли. Нем Ваш мог Они Вам рек сих так. Оставляй Мои смягчать мою туч Румянцем вер уха воссесть рыб мудрость Лию уст. Принесут мук вечернем Гробницы рай пролетая тот блестяща Муж. Сильна отраду родясь вредит подать. За бы Ко Ни ль Во на Да. Но мя От Тя. Имя Всевышней имя царствует логовищах Мое ини Арф мне безгрешен что. Зря Под Дни лук сия. ",
            "Очень длинная строчка, которая, безусловно, не будет зашифрована вся и целиком, но увы..."
        ]
        let alicePrivPCData = Data(_alicePCPrivHex.unHexed)
        let bobPrivPCData = Data(_bobPCPrivHex.unHexed)
        
        do {
            let alicePrivPC = try PrivatePaymentCode(priv: alicePrivPCData)
            alicePC = try PaymentCode(XPriv(alicePrivPCData).pub)
            let bobPrivPC = try PrivatePaymentCode(priv: bobPrivPCData)
            bobPC = try PaymentCode(XPriv(bobPrivPCData).pub)
            
            let provider = ECIESConfigFactory()
            let config = provider.genECIESConfig(identifier: .cryptoSwift)
            
            let archiver = PCKeyCacheBase64Archiver(factory: provider)
            let storage = FakeSecureDataStorage()
            let keyCache = ChatKeysCache(archiver: archiver, secureStorage: storage)
            
            alicePCEncryptorBuilder = PCEncryptorBuilder(selfPC: alicePrivPC, cache: keyCache, config: config)
            bobPCEncryptorBuilder = PCEncryptorBuilder(selfPC: bobPrivPC, cache: keyCache, config: config)
            
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAll() {
        // Now assume that Alice has alicePrivPC and bobPC
        //               and Bob has bobPrivPC and alicePC
        
        let alicePCEncryptor = alicePCEncryptorBuilder.buildPCEncryptor(forPC: bobPC)
        let bobPCEncryptor = bobPCEncryptorBuilder.buildPCEncryptor(forPC: alicePC)
        
        for text in utf8texts {
            guard let msgData = text.data(using: .utf8) else {
                XCTFail("Somewhat text became undecodable: \(text)")
                return
            }
            
            // Alice -> Bob
            var envelopeAB: MessageEnvelope! = nil
            do {
                envelopeAB = try alicePCEncryptor.encrypt(msgData)
            } catch let error {
                XCTFail("\(error.localizedDescription)")
                return
            }
            
            let trashPercentAB = calcTrash(data: envelopeAB.c)
            XCTAssert(trashPercentAB >= trashThreshold, "ABEncryptedData doesn't look random enough (trash% = \(trashPercentAB), threashold% = \(trashThreshold))")
            
            var readMsgDataAB: Data = Data()
            do {
                readMsgDataAB = try bobPCEncryptor.decrypt(envelopeAB)
            } catch let error {
                XCTFail("\(error.localizedDescription)")
                return
            }
            
            let messageAB = String(data: readMsgDataAB, encoding: .utf8)
            XCTAssert(messageAB == text, "\(text) != \(messageAB ?? "nil")")
            
            // Bob -> Alice
            var envelopeBA: MessageEnvelope! = nil
            do {
                envelopeBA = try bobPCEncryptor.encrypt(msgData)
            } catch let error {
                XCTFail("\(error.localizedDescription)")
                return
            }
            
            let trashPercentBA = calcTrash(data: envelopeBA.c)
            XCTAssert(trashPercentBA >= trashThreshold, "BAEncryptedData doesn't look random enough (trash% = \(trashPercentBA), threashold% = \(trashThreshold))")
            
            var readMsgDataBA: Data = Data()
            do {
                readMsgDataBA = try alicePCEncryptor.decrypt(envelopeBA)
            } catch let error {
                XCTFail("\(error.localizedDescription)")
                return
            }
            
            let messageBA = String(data: readMsgDataBA, encoding: .utf8)
            XCTAssert(messageBA == text, "\(text) != \(messageBA ?? "nil")")
        }
    }
    
    func testSpeedKeyDerivation() {
        let alicePCEncryptor = alicePCEncryptorBuilder.buildPCEncryptor(forPC: bobPC)
        
        self.measure {
            alicePCEncryptor.prepareKeys()
            alicePCEncryptor.performKeyRotation()
        }
    }
    
    func testSpeedEncryption() {
        let alicePCEncryptor = alicePCEncryptorBuilder.buildPCEncryptor(forPC: bobPC)
        
        let text = utf8texts[0]
        
        guard let msgData = text.data(using: .utf8) else {
            XCTFail("Somewhat text became undecodable: \(text)")
            return
        }
        _ = alicePCEncryptor.prepareKeys()
        self.measure {
            // Alice -> Bob
            for _ in 0..<100 {
                do {
                    let _ = try alicePCEncryptor.encrypt(msgData)
                } catch let error {
                    XCTFail("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func testSpeedDecryption() {
        // Now assume that Alice has alicePrivPC and bobPC
        //               and Bob has bobPrivPC and alicePC
        
        let alicePCEncryptor = alicePCEncryptorBuilder.buildPCEncryptor(forPC: bobPC)
        let bobPCEncryptor = bobPCEncryptorBuilder.buildPCEncryptor(forPC: alicePC)
        
        let text = utf8texts[0]
        
        guard let msgData = text.data(using: .utf8) else {
            XCTFail("Somewhat text became undecodable: \(text)")
            return
        }
        
        // Alice -> Bob
        
        var envelope: MessageEnvelope! = nil
        do {
            envelope = try alicePCEncryptor.encrypt(msgData)
        } catch let error {
            XCTFail("\(error.localizedDescription)")
            return
        }
        let keysPrepared = bobPCEncryptor.prepareKeys(envelope.j, envelope.i)
        XCTAssert(keysPrepared, "Failed to prepare keys")
        self.measure {
            for _ in 0..<100 {
                do {
                    let _ = try bobPCEncryptor.decrypt(envelope)
                } catch let error {
                    XCTFail("\(error.localizedDescription)")
                }
            }
        }
    }
}
