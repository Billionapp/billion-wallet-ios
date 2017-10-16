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

class PaymentCodeEncryptionTests: XCTestCase {
    
    let trashThreshold: Double = 0.56
    
    let _alicePCPrivHex = "0a5c1795378b3ba756efcb5ca47e605c3f4f8bcff99eced897b45a4b051e980d671af9f65904632e2dcc0c6ad314e11d53fc82fa4c4ea27a4a14eccecc478fee"
    let _bobPCPrivHex = "b7f3d1104fc72d8226b9d78ce9340aa8be76d979390c22cf491104775813a6421db1243aaa57c7fbea3072249c1bd4dab9482b4fee4d25e1c69707e8144dc137"
    
    var alicePrivPCData: Data = Data()
    var bobPrivPCData: Data = Data()
    var texts: [String] = []
    
    override func setUp() {
        super.setUp()
        texts = [
            "бля",
            "Оно увы тощ мой ран так Уже мню. Натягивают БЕССМЕРТИЕ процветают. Те Ни взирайте гармонию ИЗ До охранены на Нетленье нечестье Вы приносит. Ты от ИЗ со По им. Всем верх Сион СИЛУ Уста. Satoshi WuS h3r3. Нечестивы от ее восстанет Христовых Ея трепетала он Ливанских ах. Мы да Во ум же ад Тя ею. Презренным смертельно освещенных сокровенно",
            "Волшебное Искушения богатство. . Выходил трудись зовущий кротить любящих уясняся. Тму див шум увы Чей рек яры Вот. Во Ум Ея ее ея то До. Бытие Еще огнем как Оно Рек Душ сих гласа велел жирны Падши. Ком угодны Терпел нас Блюдут Случай чей Твоего ков ему дивный. Миг Чья сон ним Уже Быв дна сих.",
            "Позабыть Взыграет вселенну смиренну незлобье Божество. Красой долгим концов лесами Котору являли. Нем Ваш мог Они Вам рек сих так. Оставляй Мои смягчать мою туч Румянцем вер уха воссесть рыб мудрость Лию уст. Принесут мук вечернем Гробницы рай пролетая тот блестяща Муж. Сильна отраду родясь вредит подать. За бы Ко Ни ль Во на Да. Но мя От Тя. Имя Всевышней имя царствует логовищах Мое ини Арф мне безгрешен что. Зря Под Дни лук сия. ",
            "Очень длинная строчка, которая, безусловно, не будет зашифрована вся и целиком, но увы..."
        ]
        alicePrivPCData = Data(_alicePCPrivHex.unHexed)
        bobPrivPCData = Data(_bobPCPrivHex.unHexed)
    }
    
    func testAll() {
        let alicePrivPC = PrivatePaymentCode(priv: alicePrivPCData)
        let alicePC = PaymentCode(XPriv(alicePrivPCData).pub)
        let bobPrivPC = PrivatePaymentCode(priv: bobPrivPCData)
        let bobPC = PaymentCode(XPriv(bobPrivPCData).pub)
        
        // Now assume that Alice has alicePrivPC and bobPC
        //               and Bob has bobPrivPC and alicePC
        
        var alicePCEncryptor = PaymentCodeEncryption(alicePrivPC, bobPC)
        var bobPCEncryptor = PaymentCodeEncryption(bobPrivPC, alicePC)
        
        for text in texts {
            guard let msgData = text.data(using: .utf8) else {
                XCTFail("Somewhat text became undecodable: \(text)")
                return
            }
            
            // Alice -> Bob
            let envelopeAB = alicePCEncryptor.encrypt(msgData)
            
            XCTAssertNotNil(envelopeAB)
            guard envelopeAB != nil else { return }
            
            let trashPercentAB = calcTrash(data: envelopeAB!.c)
            XCTAssert(trashPercentAB >= trashThreshold, "ABEncryptedData doesn't look random enough (trash% = \(trashPercentAB), threashold% = \(trashThreshold))")
            
            let readMsgDataAB = bobPCEncryptor.decrypt(envelopeAB!)
            XCTAssertNotNil(readMsgDataAB)
            guard readMsgDataAB != nil else { return }
            
            let messageAB = String(data: readMsgDataAB!, encoding: .utf8)
            XCTAssert(messageAB == text, "\(text) != \(messageAB ?? "nil")")
        
            // Bob -> Alice
            let envelopeBA = bobPCEncryptor.encrypt(msgData)
            
            XCTAssertNotNil(envelopeBA)
            guard envelopeBA != nil else { return }
            
            let trashPercentBA = calcTrash(data: envelopeBA!.c)
            XCTAssert(trashPercentBA >= trashThreshold, "BAEncryptedData doesn't look random enough (trash% = \(trashPercentBA), threashold% = \(trashThreshold))")
            
            let readMsgDataBA = alicePCEncryptor.decrypt(envelopeBA!)
            XCTAssertNotNil(readMsgDataBA)
            guard readMsgDataBA != nil else { return }
            
            let messageBA = String(data: readMsgDataBA!, encoding: .utf8)
            XCTAssert(messageBA == text, "\(text) != \(messageBA ?? "nil")")
        }
    }
    
    func testSpeedKeyDerivation() {
        let alicePrivPC = PrivatePaymentCode(priv: alicePrivPCData)
        let bobPC = PaymentCode(XPriv(bobPrivPCData).pub)
        
        var alicePCEncryptor = PaymentCodeEncryption(alicePrivPC)
        alicePCEncryptor.otherPC = bobPC
        
        self.measure {
            _ = alicePCEncryptor.prepareKeys()
            alicePCEncryptor.cache = nil
        }
    }
    
    func testSpeedEncryption() {
        let alicePrivPC = PrivatePaymentCode(priv: alicePrivPCData)
        let bobPC = PaymentCode(XPriv(bobPrivPCData).pub)
        
        var alicePCEncryptor = PaymentCodeEncryption(alicePrivPC)
        alicePCEncryptor.otherPC = bobPC
        
        let text = texts[0]
        
        guard let msgData = text.data(using: .utf8) else {
            XCTFail("Somewhat text became undecodable: \(text)")
            return
        }
        _ = alicePCEncryptor.prepareKeys()
        self.measure {
            // Alice -> Bob
            for _ in 0..<100 {
                let _ = alicePCEncryptor.encrypt(msgData)
            }
        }
    }
    
    func testSpeedDecryption() {
        let alicePrivPC = PrivatePaymentCode(priv: alicePrivPCData)
        let alicePC = PaymentCode(XPriv(alicePrivPCData).pub)
        let bobPrivPC = PrivatePaymentCode(priv: bobPrivPCData)
        let bobPC = PaymentCode(XPriv(bobPrivPCData).pub)
        
        // Now assume that Alice has alicePrivPC and bobPC
        //               and Bob has bobPrivPC and alicePC
        
        var alicePCEncryptor = PaymentCodeEncryption(alicePrivPC, bobPC)
        var bobPCEncryptor = PaymentCodeEncryption(bobPrivPC, alicePC)
        
        let text = texts[0]
        
        guard let msgData = text.data(using: .utf8) else {
            XCTFail("Somewhat text became undecodable: \(text)")
            return
        }
        
        // Alice -> Bob
        guard let envelope = alicePCEncryptor.encrypt(msgData) else { return }
        _ = bobPCEncryptor.prepareKeys(envelope.j, envelope.i)
        self.measure {
            for _ in 0..<100 {
                let _ = bobPCEncryptor.decrypt(envelope)
            }
        }
    }
}
