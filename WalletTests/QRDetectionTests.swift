//
//  QRDetectionTests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class QRDetectionTests: XCTestCase {
    
    //given
    let _pcString = "PM8TJNLQYUKVUiHacsb5x3SLjuSugPkf7tnYj8APxttRxDm8MADhsFpHhspQiLp2n7EarSM6bWmFAsFBCPwonZoMjXuvCQ4PpyggUfWhpeDYB4NksfqS"
    
    override func setUp() {
        super.setUp()
    }
    
    func testImageDownload() {
        let image = #imageLiteral(resourceName: "qrPaymentCode")
        let imageWorksOn11OSOnly = #imageLiteral(resourceName: "qrPhoto")
        
        //MARK: - with imagePhoto test Failed -
        performQRCodeDetection(image: CIImage(image: image)!, success: { (str) in
            XCTAssert(_pcString == str)
        }) { (errorString) in
            XCTFail()
        }
    }
    
    
}
