//
//  PCEcryptionQueueTests.swift
//  WalletTests
//
//  Created by Evolution Group Ltd on 21.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class PCEcryptionQueueTests: XCTestCase {
    
    let qKeyIndex: UInt32 = (1<<31)-1
    
    let aPriv = "148740a838e3e28e0ead7b22302db85d53c88190c9e866f79fe6d47957c74ddff3aab33539b9fbc44cbb79cd358ecaa20c47f6e4d4fa3f56f69cb4be9b90d5c6".unHexed
    let bPriv = "30a5bd1de2ebc14797e84a7fac45e17f70aa9ce26807c4dff38902b274d5c9e8b187cb7c52b5d43b8fc8a464cc8d98b8ff0e856fba797ef445c7414b879e8466".unHexed
    
    let _aPC = "PM8TJYVGoxvAcfFVUNGofABDmRkmbTzVHh3RzFz2F8XRw5S3VWvs59khu9j4qVRYbjWaxGMrFbtF5n14raWavnT7FxUrYUoRFVk5cPzkkWffwJDa45Qg"
    let _bPC = "PM8TJPGib1t2DtVSGDTBy8BG6K7omPXhVUECnhWQAr743evULFm5h2N4CR3G9MDfmGbGEgAH9RNLDui4tzdrjLdZ2e553cqgNrt9bSMvuNvKququELbz"
    
    private func privToPub(_ priv: Priv) -> Pub {
        let point = Secp256k1.pointGen(priv.uint256)
        return Pub(point)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    func testEphemeralKeysEquality() {
        let aPrivData = Data(aPriv)
        let bPrivData = Data(bPriv)
        
        guard let aPrivPC = try? PrivatePaymentCode(priv: aPrivData) else {
            
            return
        }
        
        guard let bPrivPC = try?  PrivatePaymentCode(priv: bPrivData) else {
            
            return
        }
        
        XCTAssert(aPrivPC.serializedString == _aPC, "\(aPrivPC.serializedString) != \(_aPC)")
        XCTAssert(bPrivPC.serializedString == _bPC, "\(bPrivPC.serializedString) != \(_bPC)")
        
        guard let _ = aPrivPC.ephemeralSendKey(to: bPrivPC, i: qKeyIndex),
            let _ = aPrivPC.ephemeralReceiveKey(from: bPrivPC, i: qKeyIndex),
            let _ = bPrivPC.ephemeralSendKey(to: aPrivPC, i: qKeyIndex),
            let _ = bPrivPC.ephemeralReceiveKey(from: aPrivPC, i: qKeyIndex) else {
            XCTFail("Failed to create keys")
            return
        }
    }
}
