//
//  PKCS7PaddingTests.swift
//  BillionWallet
//
//  Created by Evolution Group on 23.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class PKCS7PaddingTests: XCTestCase {
    
    var blockSizes: [Int] = []
    var texts: [String] = []
    
    override func setUp() {
        super.setUp()
        
        blockSizes = [128/8, 160/8, 192/8, 256/8, 512/8]
        texts = ["Пре ﻿Кто тел кое нам зол шум. . . Отвсюду тих тме рок унизить тартара Попрать ему мертвой буй зва склонит. Ль вечностью се румянятся На им ко Ты обносимым Мы Ко. Сан ﻿Кто Чей мне мое Век раз. Им Из кедр мета до об реку. . ",
                 "Ему падут хвалы чтя умы лед Оно коему той. Бы ты всходят Доволен та средине да плакать двигнет Мы до Тя. Бог тем рыб Отч. Надеетесь на Умудряйся мя По наполняяй Из. Очи Хор туч сне зол род яра шум. Ваш Век Бог кто лук они Оно Мои. Стихия дар пою защиту дна тем Век прежде",
                 "кто. Звездны богачей неправд. Бледному принести звездной подобные теряться проблеск. Се лобно высот Уметь вы Се звона об Долги яр от втечь. Душ Сын вам чья Род это тул. Мертвила гармония отческих Угнетает вчиняешь. Лию увы Див ним век Кой умы муз. Сблизить лежащего изъемлет Приемлем холмятся.",
                 ""]
    }
    
    func testExtendRemove() {
        
        for size in blockSizes {
            for text in texts {
                let textData = text.data(using: .utf8)!
                let paddedData = LocalCrypto.PKCS7Padding.extend(textData, forBlockSize: size)
                
                XCTAssert(paddedData != nil, "Padded data for text \"\(text)\" is nil.")
                XCTAssert(paddedData != textData, "Padding for text \"\(text)\" doesn't modify data.")
                
                let unPaddedData = LocalCrypto.PKCS7Padding.remove(for: paddedData!, withBlockSize: size)
                
                XCTAssert(unPaddedData != nil, "Text restore has failed for text \"\(text)\"")
                XCTAssert(unPaddedData == textData, "Unpadded message doesn't match original for text \"\(text)\"")
            }
        }
    }
}
