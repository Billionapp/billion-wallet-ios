//
//  FiatConverterTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class FiatConverterTests: XCTestCase {

    // assuming locale en_US
    
    class FakeRatesSource: RatesSource {
        func rateForCurrency(_ currency: Currency) -> Rate? {
            switch(currency.code) {
            case "RUB":
                return Rate(currencyCode: "RUB",
                            btc: 267576.63475,
                            blockTimestamp: 1507550182)
            case "CNY":
                return Rate(currencyCode: "CNY",
                            btc: 30373.2294,
                            blockTimestamp: 1507550182)
            case "JPY":
                return Rate(currencyCode: "JPY",
                            btc: 516393.03705,
                            blockTimestamp: 1507550182)
                
            default:
                return Rate(currencyCode: "USD",
                            btc: 4584.5,
                            blockTimestamp: 1507550182)
            }
        }
    }
    
    var _rubString: String = "RUB40,144.53"
    var _usdString: String = "$687.81"
    var _cnyString: String = "CN¥4,556.9"
    var _jpyString: String = "¥77,474"
    
    var _satoshiValue: UInt64 = 15003001
    
    var _rubSatoshi: UInt64 = 15003002
    var _usdSatoshi: UInt64 = 15002944
    var _cnySatoshi: UInt64 = 15003014
    var _jpySatoshi: UInt64 = 15002913
    
    let MAXDELTA = 3
    
    var source: RatesSource!
    var locale: Locale!
    
    override func setUp() {
        super.setUp()
        source = FakeRatesSource()
        locale = Locale(identifier: "en_US")
    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    func distanceOk(_ a: UInt64, _ b: UInt64) -> Bool {
        if a > b {
            return (a - b) < MAXDELTA
        } else {
            return (b - a) < MAXDELTA
        }
    }

    func testConvertToBtc() {
        guard let rub = CurrencyFactory.currencyWithCode("RUB"),
            let usd = CurrencyFactory.currencyWithCode("USD"),
            let cny = CurrencyFactory.currencyWithCode("CNY"),
            let jpy = CurrencyFactory.currencyWithCode("JPY") else {
                XCTFail("Could not create currencies")
                return
        }
        
        let rubConverter = FiatConverter(currency: rub, ratesSource: source, locale: locale)
        let usdConverter = FiatConverter(currency: usd, ratesSource: source, locale: locale)
        let cnyConverter = FiatConverter(currency: cny, ratesSource: source, locale: locale)
        let jpyConverter = FiatConverter(currency: jpy, ratesSource: source, locale: locale)
        
        let rubBtc = rubConverter.btcValueFromFiatString(_rubString)
        let usdBtc = usdConverter.btcValueFromFiatString(_usdString)
        let cnyBtc = cnyConverter.btcValueFromFiatString(_cnyString)
        let jpyBtc = jpyConverter.btcValueFromFiatString(_jpyString)
        
        XCTAssert(distanceOk(rubBtc, _rubSatoshi), "Values not match \(rubBtc) != \(_rubSatoshi)")
        XCTAssert(distanceOk(usdBtc, _usdSatoshi), "Values not match \(usdBtc) != \(_usdSatoshi)")
        XCTAssert(distanceOk(cnyBtc, _cnySatoshi), "Values not match \(cnyBtc) != \(_cnySatoshi)")
        XCTAssert(distanceOk(jpyBtc, _jpySatoshi), "Values not match \(jpyBtc) != \(_jpySatoshi)")
    }

    func testConvertFromBtc() {
        guard let rub = CurrencyFactory.currencyWithCode("RUB"),
            let usd = CurrencyFactory.currencyWithCode("USD"),
            let cny = CurrencyFactory.currencyWithCode("CNY"),
            let jpy = CurrencyFactory.currencyWithCode("JPY") else {
                XCTFail("Could not create currencies")
                return
        }
        
        let rubConverter = FiatConverter(currency: rub, ratesSource: source, locale: locale)
        let usdConverter = FiatConverter(currency: usd, ratesSource: source, locale: locale)
        let cnyConverter = FiatConverter(currency: cny, ratesSource: source, locale: locale)
        let jpyConverter = FiatConverter(currency: jpy, ratesSource: source, locale: locale)
        
        let rubString = rubConverter.fiatStringForBtcValue(_satoshiValue)
        let usdString = usdConverter.fiatStringForBtcValue(_satoshiValue)
        let cnyString = cnyConverter.fiatStringForBtcValue(_satoshiValue)
        let jpyString = jpyConverter.fiatStringForBtcValue(_satoshiValue)
        
        XCTAssert(rubString == _rubString, "Values not match \(rubString) != \(_rubString)")
        XCTAssert(usdString == _usdString, "Values not match \(usdString) != \(_usdString)")
        XCTAssert(cnyString == _cnyString, "Values not match \(cnyString) != \(_cnyString)")
        XCTAssert(jpyString == _jpyString, "Values not match \(jpyString) != \(_jpyString)")
    }
    
    func testConvertToAndFromBtc() {
        // TODO: Make round trip test
    }

    func testPrecision() {
        // TODO: Make precision test
    }
}
