//
//  PaymentCodeContactProtocol.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol PaymentCodeContactProtocol {
    var paymentCode: String { get }
    var firstUnusedIndex: Int { get set }
    var receiveAddresses: [String] { get set }
    var notificationTxHash: String? { get set}
}

extension PaymentCodeContactProtocol {
    
    var isNotificationTxNeededToSend: Bool {
        return notificationTxHash == nil
    }
    
    func isContactForNotificationTransaction(txHash: UInt256S) -> Bool {
        return notificationTxHash == txHash.data.hex
    }
    
    mutating func addressToSend() -> String? {
        let selfPCPrivData = BRWalletManager.getKeychainPaymentCodePriv(forAccount: 0)
        let selfPCInternal = PrivatePaymentCode(priv: selfPCPrivData)
        
        guard
            let recipientPC = try? PaymentCode(with: paymentCode),
            let key = selfPCInternal.ethemeralSendBRKey(to: recipientPC, i: UInt32(firstUnusedIndex)) else {
            return nil
        }
        
        incrementFirstUnusedIndex()
        
        return key.address
    }

    static func generateReceiveAddresses(pc: String, range: CountableRange<Int>) -> [String] {
        var seedPhrase: String!
#if TEST_SUITE
        seedPhrase = TestConstants.seedPhrase
#else
        seedPhrase = BRWalletManager.getMnemonicKeychainString()!
#endif
        let seed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil)!
        
        let currentAccount = AccountManager.shared.currentAccountNumber
        let contactPC = try! PaymentCode(with: pc)
        let pcPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: currentAccount, fromSeed: seed)
        let pcInternal = PrivatePaymentCode(priv: pcPrivData)
        
        //receive addresses
        var addresses = [String]()
        for i in range {
            let receiveAddress = pcInternal.ethemeralReceiveBRKey(from: contactPC, i: UInt32(i))?.address
            addresses.append(receiveAddress!)
        }
        return addresses
    }
    
    func isContact(for transaction: BRTransaction) -> Bool {
        let outputsAddresses = transaction.outputAddresses.flatMap { $0 as? String }
        let txSet = Set(outputsAddresses)
        let pregenSet = Set(receiveAddresses)
        let intersection = txSet.intersection(pregenSet)
        return intersection.count > 0
    }
    
    mutating func incrementFirstUnusedIndex() {
        firstUnusedIndex += 1
        
        if firstUnusedIndex >= receiveAddresses.count {
            let newReceiveAddresses = Self.generateReceiveAddresses(pc: paymentCode, range: receiveAddresses.count..<receiveAddresses.count+25)
            receiveAddresses += newReceiveAddresses
        }
    }
    
}
