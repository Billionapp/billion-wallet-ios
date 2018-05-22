//
//  VersionTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class VersionTests: XCTestCase {
    
    let _versionData: [(str: String, major: String, minor: String, bugfix: String)] = [
        ("0.3.4","0","3","4"),
        ("0.3.5","0","3","5"),
        ("0.4.0","0","4","0"),
        ("0.4.1","0","4","1"),
        ("1.0.0","1","0","0"),
        ("2.0.0","2","0","0"),
        ("2.2.0","2","2","0"),
        ("2.2.3","2","2","3")
    ]
    
    let versionFromStrings: [Version] = ["0.3.4",
                                        "0.3.5",
                                        "0.4",
                                        "0.4.1",
                                        "1.0.0",
                                        "2",
                                        "2.2.0",
                                        "2.2.3"]
    
    let versionObjects: [Version] = [Version(0,3,4),
                                     Version(0,3,5),
                                     Version(0,4),
                                     Version(0,4,1),
                                     Version(1),
                                     Version(2),
                                     Version(2,2),
                                     Version(2,2,3)]
    
    func testFromString() {
        for i in 0..<_versionData.count {
            let verData = _versionData[i]
            let ver: Version = versionFromStrings[i]
            XCTAssert(ver.rawValue == verData.str, "\(ver.rawValue) != \(verData.str)")
            XCTAssert(ver.major == verData.major, "\(ver.rawValue) != \(verData.major)")
            XCTAssert(ver.minor == verData.minor, "\(ver.rawValue) != \(verData.minor)")
            XCTAssert(ver.bugfix == verData.bugfix, "\(ver.rawValue) != \(verData.bugfix)")
            
            let verObj: Version = versionObjects[i]
            XCTAssert(verObj.rawValue == verData.str, "\(verObj.rawValue) != \(verData.str)")
            XCTAssert(verObj.major == verData.major, "\(verObj.rawValue) != \(verData.major)")
            XCTAssert(verObj.minor == verData.minor, "\(verObj.rawValue) != \(verData.minor)")
            XCTAssert(verObj.bugfix == verData.bugfix, "\(verObj.rawValue) != \(verData.bugfix)")
            
            XCTAssert(ver == verObj, "\(ver) != \(verObj)")
        }
    }
    
    func testCompare() {
        for i in 0..<(versionFromStrings.count-1) {
            let verLow = versionFromStrings[i]
            let verHigh = versionFromStrings[i+1]
            XCTAssert(verLow < verHigh, "Comparability test failed: \(verLow) !< \(verHigh)")
        }
    }
}
