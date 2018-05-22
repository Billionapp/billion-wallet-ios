//
//  ECIESTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22.06.17.
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

class ECIESTests: XCTestCase {
    let trashThreshold: Double = 0.6
    
    var aliceKey: UInt256S!
    var bobKey: UInt256S!
    
    var texts: [String] = []
    
    override func setUp() {
        super.setUp()
        aliceKey = Crypto.Random.uInt256S()
        bobKey = Crypto.Random.uInt256S()
        
        texts = [
            "Оно увы тощ мой ран так Уже мню. Натягивают БЕССМЕРТИЕ процветают. Те Ни взирайте гармонию ИЗ До охранены на Нетленье нечестье Вы приносит. Ты от ИЗ со По им. Всем верх Сион СИЛУ Уста. . Нечестивы от ее восстанет Христовых Ея трепетала он Ливанских ах. Мы да Во ум же ад Тя ею. Презренным смертельно освещенных сокровенно",
            "Волшебное Искушения богатство. . Выходил трудись зовущий кротить любящих уясняся. Тму див шум увы Чей рек яры Вот. Во Ум Ея ее ея то До. Бытие Еще огнем как Оно Рек Душ сих гласа велел жирны Падши. Ком угодны Терпел нас Блюдут Случай чей Твоего ков ему дивный. Миг Чья сон ним Уже Быв дна сих.",
            "Позабыть Взыграет вселенну смиренну незлобье Божество. Красой долгим концов лесами Котору являли. Нем Ваш мог Они Вам рек сих так. Оставляй Мои смягчать мою туч Румянцем вер уха воссесть рыб мудрость Лию уст. Принесут мук вечернем Гробницы рай пролетая тот блестяща Муж. Сильна отраду родясь вредит подать. За бы Ко Ни ль Во на Да. Но мя От Тя. Имя Всевышней имя царствует логовищах Мое ини Арф мне безгрешен что. Зря Под Дни лук сия. ",
            "Очень длинная строчка, которая, безусловно, не будет зашифрована вся и целиком, но увы..."
        ]
    }
    
    func testAll() {
        let config = ECIESConfigFactory().genECIESConfig()
        let ecies_a = ECIES(with: config)
        let ecies_b = ECIES(with: config)
        let alicePub = ECIES.privToPub(aliceKey)
        let bobPub = ECIES.privToPub(bobKey)
        
        do {
            try ecies_a.setUp(priv: aliceKey, pub: bobPub)
            try ecies_b.setUp(priv: bobKey, pub: alicePub)
        } catch let error {
            XCTFail("\(error.localizedDescription)")
        }
        
        XCTAssert(ecies_a.Ke == ecies_b.Ke, "Encryption key values for Alice and Bob don't match")
        XCTAssert(ecies_a.Km == ecies_b.Km, "MAC key values for Alice and Bob don't match")
        
        for message in texts {
            do {
                let msgData = message.data(using: .utf8)!
                let msgCypher_ab = try ecies_a.encrypt(msgData)
                let msgCypher_ba = try ecies_b.encrypt(msgData)
                
                let trashPercent_ab = calcTrash(data: msgCypher_ab.c)
                XCTAssert(trashPercent_ab >= trashThreshold, "AB encrypted data doesn't look random enough (trash% = \(trashPercent_ab), threashold% = \(trashThreshold))")
                let trashPercent_ba = calcTrash(data: msgCypher_ba.c)
                XCTAssert(trashPercent_ba >= trashThreshold, "BA encrypted data doesn't look random enough (trash% = \(trashPercent_ba), threashold% = \(trashThreshold))")
                
                let msgDecypher_ab = try ecies_b.decrypt(msgCypher_ab.c, mac: msgCypher_ab.d)
                let msgDecypher_ba = try ecies_a.decrypt(msgCypher_ba.c, mac: msgCypher_ba.d)
                
                let msg_ab = String(data: msgDecypher_ab, encoding: .utf8)
                let msg_ba = String(data: msgDecypher_ba, encoding: .utf8)
                XCTAssert(message == msg_ab, "Decrypted message Alice->Bob is invalid")
                XCTAssert(message == msg_ba, "Decrypted message Bob->Alice is invalid")
                XCTAssert(msgData == msgDecypher_ab, "Decrypted message data Alice->Bob don't match original")
                XCTAssert(msgData == msgDecypher_ba, "Decrypted message data Bob->Alice don't match original")
            } catch let error {
                XCTFail("\(error.localizedDescription)")
            }
        }
    }
    
    func testSpeed() {
        let configA = ECIESConfigFactory().genECIESConfig()
        let ecies_a = ECIES(with: configA)
        let bobPub = ECIES.privToPub(bobKey)
        do {
            try ecies_a.setUp(priv: aliceKey, pub: bobPub)
        } catch let error {
            XCTFail("\(error.localizedDescription)")
        }
        let text = texts[0]
        let msgData = text.data(using: .utf8)!
        self.measure {
            for _ in 0..<10 {
                do {
                    let msgCypher_ab = try ecies_a.encrypt(msgData)
                    let _ = try ecies_a.decrypt(msgCypher_ab.c, mac: msgCypher_ab.d)
                } catch let error {
                    XCTFail("\(error.localizedDescription)")
                }
            }
        }
    }
    
    func testSpeedSetup() {
        let configA = ECIESConfigFactory().genECIESConfig(identifier: .cryptoSwift)
        
        let bobPub = ECIES.privToPub(bobKey)
        self.measure {
            do {
                let ecies_a = ECIES(with: configA)
                try ecies_a.setUp(priv: aliceKey, pub: bobPub)
            } catch let error {
                XCTFail("\(error.localizedDescription)")
            }
        }
    }
    
    func testSpeedLocalCrypto() {
        let configA = ECIESConfigFactory().genECIESConfig(identifier: .localCrypto)
        let ecies_a = ECIES(with: configA)
        let bobPub = ECIES.privToPub(bobKey)
        do {
            try ecies_a.setUp(priv: aliceKey, pub: bobPub)
        } catch let error {
            XCTFail("\(error.localizedDescription)")
        }
        let text = texts[0]
        let msgData = text.data(using: .utf8)!
        self.measure {
            for _ in 0..<10 {
                do {
                    let msgCypher_ab = try ecies_a.encrypt(msgData)
                    let _ = try ecies_a.decrypt(msgCypher_ab.c, mac: msgCypher_ab.d)
                } catch let error {
                    XCTFail("\(error.localizedDescription)")
                }
            }
        }
    }
}
