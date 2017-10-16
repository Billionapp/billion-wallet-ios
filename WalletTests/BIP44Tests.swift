//
//  BIP44Tests.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import XCTest
@testable import BillionWallet

class BIP44Tests: XCTestCase {
    // given constants
    static let mnemonic = "foster crush demand apart nut lobster common problem since caught provide curious"
	let seedData = BRBIP39Mnemonic().deriveKey(fromPhrase: mnemonic, withPassphrase: nil)
    
    // then constants
    var _seedHex = "eecc62702f0b9dcf14cdacab6e5ff08a9472d53426f303271b921e8b6cf1b82ea4375066b91a7a97450bea431305bd702cf077d445b195c2dad33955ff86db1b"
    var _addr_m4400 = "1LJjWW1RL1orwhYAvguzwNiXd27HkUTxBp"
    var _pubHex_m4400 = "02af71232d51adf21cfa8a7845e4475037d480e1524d9a5bf28ab27203ad4e967f"
    
    // m/44'/0'/0'/0 - external  chain
    var _extChainAddr = "16aBKj1uK7P3qLGCcATbcVNjw5bqdYZQr1"
    var _pubKeyHexExtChain = "02174b38d2103cc89969dd4f2bd64137458f10ef51738f9d0cabc498e373f990db"
    
    // m/44'/0'/0'/1 - internal change chain
    var _interChainAddr = "1Dcxume3a5gkawTBXbax893kp65Wr1s3Ef"
    var _pubKeyHexInterChain = "03c5d2e6159325c42cd64edc00b252aafa4a374b60158e8ce28a7e6f4eb9d810e1"
    
    // m/345'/0'/0'/0' - mnemonic auth id
    var _mnemAuthIdAddr = "1KH9oiDUuGWhZGxChrTpCNezMmeZHNU13g"
    var _mnemAuthPubHexKey = "028f1c444dd6b55146cb72f84ede4ee732173b2a26eb237d258afcee990bc10c24"
    
    func testAccountRootKey() {
        let accPrivKey = BIP44Sequence.deriveAccountRootXPrivateKey(forAccountNumber: 0, fromSeed: seedData!)
        let accPubKey = BIP44Sequence.deriveAccountRootPublicKey(forAccountNumber: 0, fromSeed: seedData!)
        
        let keyuint256 = UInt256S(data: accPrivKey)
        let addr = BRKey(secret: keyuint256.uint256, compressed: true)?.address
        
        XCTAssert(seedData?.hex == _seedHex)
        XCTAssert(addr == _addr_m4400, "\(addr!) != \(_addr_m4400)")
        XCTAssert(accPubKey.hex == _pubHex_m4400, "\(accPubKey.hex) != \(_pubHex_m4400)")
    }
    
    func testPrivateKeyForAccountNumber() {
        var  isInternal = false
		let externalPrivKey = BIP44Sequence.derivePrivKey(forAccountNumber: 0, fromSeed: seedData, isInternalChain: isInternal)
        var uint = UInt256S(data: externalPrivKey!)
        var address = BRKey(secret: uint.uint256, compressed: true)?.address
        //Address external chain m/44'/0'/0'/0
        XCTAssert(address == _extChainAddr, "\(address!) != \(_extChainAddr)")
        
        isInternal = true
        let internalPrivKey = BIP44Sequence.derivePrivKey(forAccountNumber: 0, fromSeed: seedData, isInternalChain: isInternal);
        uint = UInt256S(data: internalPrivKey!)
            
        address = BRKey(secret: uint.uint256, compressed: true)?.address
        //Address internal chain m/44'/0'/0'/1
        XCTAssert(address == _interChainAddr, "\(address!) != \(_interChainAddr)")
		
		let internalPubKey = BIP44Sequence.derivePubKey(forAccountNumber: 0, fromSeed: seedData!, isInternalChain: isInternal);
		//Pubkey internal chain m/44'/0'/0'/1
		XCTAssert(internalPubKey?.hex == _pubKeyHexInterChain, "\(internalPubKey?.hex ?? "nil") != \(_pubKeyHexInterChain)")
		
		isInternal = false
		let externalPubKey = BIP44Sequence.derivePubKey(forAccountNumber: 0, fromSeed: seedData!, isInternalChain: isInternal);
		//PubKey external chain m/44'/0'/0'/0
		XCTAssert(externalPubKey?.hex == _pubKeyHexExtChain, "\(externalPubKey?.hex ?? "nil") != \(_pubKeyHexExtChain)")
    }
	
	func testMnemonicAuthId() {
		let mnemonicAuthIdXPrivateKey = BIP44Sequence.deriveMnemonicAuthIdXPrivateKey(forAccountNumber: 0, fromSeed: seedData);
        let uint = UInt256S(data: mnemonicAuthIdXPrivateKey!)
		let address = BRKey(secret: uint.uint256, compressed: true)?.address
		//Address m/345'/0'/0'0'
		XCTAssert(address == _mnemAuthIdAddr, "\(address ?? "nil") != \(_mnemAuthIdAddr)")
	}
}
