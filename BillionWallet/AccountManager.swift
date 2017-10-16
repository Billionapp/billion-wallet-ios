//
//  AccountManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class AccountManager {
    // MARK: - Properties
    static let shared = AccountManager()
	var currentAccountNumber: UInt32 = 0
    private let curve = Curve25519()
    private var authIDXPriv: String?
    var timestamp: Int?
    
    var currentWalletDigest: String? {
        return BRWalletManager.sharedInstance()?.getKeychainWalletDigest(forAccount: currentAccountNumber)
    }
	
	var currentUdid: String? {
		guard let udid = BRWalletManager.getKeyChainUdid(forAccountNumber: currentAccountNumber) else {
            return nil
        }

        return udid
    }
    
    var currentSecret: Data {
        guard let secret = BRWalletManager.getKeyChainSecretDH(forAccount: currentAccountNumber) else {
            let newSecret = Crypto.Random.data(32)
            BRWalletManager.setKeyChainSecretDHForAccount(currentAccountNumber, secret: newSecret)
            return newSecret
        }
        
        return secret
    }
    
    var sharedPubKey: Data? {
        return BRWalletManager.getKeyChainSharedPubDH(forAccount: currentAccountNumber)
    }
    
    func createNewWalletDigest() -> String? {
        if let walDig = BRWalletManager.sharedInstance()?.getKeychainWalletDigest(forAccount: currentAccountNumber) {
            return walDig
        }
        
        var data = Data()
        guard let seedPhrase = BRWalletManager.getMnemonicKeychainString() else {return nil}
        guard let seed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil) else {return nil}
        guard let authIdXPriv = BIP44Sequence.deriveMnemonicAuthIdXPrivateKey(forAccountNumber: currentAccountNumber, fromSeed: seed) else {return nil}

        BRWalletManager.sharedInstance()?.setKeychainAuthIDXPrivForAccount(currentAccountNumber, andAuthIdXPriv: authIdXPriv)
        data = BRWalletManager.getKeychainAuthIdXPriv(forAccount: currentAccountNumber)!
    
        let privKey = Priv(data: data)
        let pubKeyGen = Secp256k1.pointGen(privKey.uint256)
        let pubKey = ECPointS(pubKeyGen)
        let walletDigest = Data(uint160: pubKey.data.hash160).base58CheckString(versionByte: 0x00)
        BRWalletManager.sharedInstance()?.setKeyChainWalletDigestForAccount(currentAccountNumber, andWalletDigest: walletDigest)
        return walletDigest
    }
    
    func getAuthIdPub() -> Data? {
        if let authId = BRWalletManager.sharedInstance()?.getKeychainAuthIDXPub(forAccount: currentAccountNumber) {
            return authId
        }
        
        guard let seedPhrase = BRWalletManager.getMnemonicKeychainString() else {return nil}
        guard let seed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil) else {return nil}
        let authIdPub = BIP44Sequence.deriveMnemonicAuthIDPubKey(forAccount: currentAccountNumber, fromSeed: seed)
        BRWalletManager.sharedInstance()?.setKeychainAuthIDXPubForAccount(currentAccountNumber, andAuthIdPub: authIdPub)
        return authIdPub
    }
    
    @discardableResult
    func createNewUdid() -> String? {
        let udid = UUID().uuidString.lowercased()
        guard udid != currentUdid else {
            return nil
        }
        
        BRWalletManager.setKeyChainUdidForAccountNumber(currentAccountNumber, andUdid: udid)
        return udid
    }
    
    func getMnemonic() -> String? {
        return BRWalletManager.sharedInstance()?.seedPhrase
    }
    
    func sharedKey(withSecret secret: Data, andServerPub key: String) {
        let dataKey = Data(base64Encoded: key)
        let sharedKey = curve.sharedKey(secret, pubK: dataKey!)
        let dataSharedKey = Data(bytes: sharedKey, count: sharedKey.count)
        BRWalletManager.setKeyChainSharedPubDHForAccount(currentAccountNumber, key: dataSharedKey)
    }
    
    func clearAccountKeychain() {
        BRWalletManager.setKeychainDictionary(nil, andKey: UDID)
        BRWalletManager.setKeychainDictionary(nil, andKey: SHARED_KEY_DH)
        BRWalletManager.setKeychainDictionary(nil, andKey: SECRET_DH)
        BRWalletManager.setKeychainDictionary(nil, andKey: WALLET_DIGEST)
        BRWalletManager.setKeychainDictionary(nil, andKey: PAYMENT_CODE)
        BRWalletManager.setKeychainDictionary(nil, andKey: PAYMENT_CODE_PRIV)
        BRWalletManager.setKeychainDictionary(nil, andKey: NOTIFICATION_ID_VER_1)
        BRWalletManager.setKeychainDictionary(nil, andKey: NOTIFICATION_ID_VER_2)
        BRWalletManager.clearKeyChain(withKey: ACCOUNT_ROOT_PRIV_KEY)
        BRWalletManager.clearKeyChain(withKey: ACCOUNT_ROOT_PUB_KEY)
        BRWalletManager.setKeychainDictionary(nil, andKey: MNEMONIC_AUTH_ID_PUB)
        BRWalletManager.setKeychainDictionary(nil, andKey: MNEMONIC_AUTH_ID_XPRIV)
    }
    
    func deleteWallet() {
        guard let seed = BRWalletManager.sharedInstance()?.seedPhrase else {
            return
        }
        
        BRWalletManager.sharedInstance()?.deleteWallet(withSeed: seed, success: { 
            Logger.info("Wallet deleted")
        }, failure: { error in
            Logger.error(error.localizedDescription)
        })
    }
    
    func getMnemonicAuthIdPriv() -> Data? {
        if let authID = BRWalletManager.getKeychainAuthIdXPriv(forAccount: currentAccountNumber) {
            return authID
        } else {
            guard let seedPhrase = BRWalletManager.getMnemonicKeychainString() else {return nil}
            guard let seed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil) else {return nil}
            guard let authIdXPriv = BIP44Sequence.deriveMnemonicAuthIDPubKey(forAccount: currentAccountNumber, fromSeed: seed) else {return nil}
            
            BRWalletManager.sharedInstance()?.setKeychainAuthIDXPrivForAccount(currentAccountNumber, andAuthIdXPriv: authIdXPriv)
            return BRWalletManager.getKeychainAuthIdXPriv(forAccount: currentAccountNumber)!
        }
    }

    func saveSelfPC(paymentCode: String) {
        BRWalletManager.setKeyChainPaymentCodeForAccount(currentAccountNumber, andPaymentCode: paymentCode)
    }
    
    func saveSelfPCPriv(paymentCodePriv: Data) {
        BRWalletManager.setKeyChainPaymentCodePrivForAccount(currentAccountNumber, andPaymentCodePriv: paymentCodePriv)
    }
    
    func saveNotificationIdVer1(notificationId: String) {
        BRWalletManager.setKeyChainNotificationIdVer1ForAccount(currentAccountNumber, andNotificationId: notificationId)
    }
    
    func saveNotificationIdVer2(notificationId: Data) {
        BRWalletManager.setKeyChainNotificationIdVer2ForAccount(currentAccountNumber, andNotificationId: notificationId)
    }
    
    func getSelfCPPriv() -> Data {
        return BRWalletManager.getKeychainPaymentCodePriv(forAccount: currentAccountNumber)
    }
}

extension AccountManager {
    
    func generatePubKDH(from secret: Data) -> String {
        let k = Curve25519().publicKey(secret)
        return Data(k).base64EncodedString()
    }
    
    func sign(message: String, mnemonicAuthIdPriv: Data) -> Data? {
        let secretUInt = UInt256S(data: mnemonicAuthIdPriv)
        guard let key = BRKey.init(secret: secretUInt.uint256, compressed: true) else { return nil }
        
        guard let data = message.data(using: .utf8)?.sha256().sha256() else {return nil}
        let uint = UInt256S(data: data)
        guard let s = key.sign(uint.uint256) else {return nil}
        return  s
    }
}
