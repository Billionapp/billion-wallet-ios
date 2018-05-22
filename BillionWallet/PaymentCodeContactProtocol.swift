//
//  PaymentCodeContactProtocol.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol PaymentCodeContactProtocol: ContactProtocol {
    var paymentCode: String { get }
    var paymentCodeObject: PaymentCode { get }
    var firstUnusedIndex: Int { get set }
    var receiveAddresses: [String] { get set }
    var notificationTxHash: String? { get set}
    var incomingNotificationTxhash: String? { get set }
    var sendAddresses: [String] { get set }
    var notificationAddress: String? { get set }
}

extension PaymentCodeContactProtocol {
    
    var isNotificationTxNeededToSend: Bool {
        return notificationTxHash == nil
    }
    
    var paymentCodeObject: PaymentCode {
        return try! PaymentCode(with: self.paymentCode)
    }
    
    func isContactForNotificationTransaction(txHash: UInt256S) -> Bool {
        return notificationTxHash == Data(txHash.data.reversed()).hex
    }
    
    func generateSendAddresses(range: CountableRange<Int>) -> [String] {
        let selfPCPrivData = BRWalletManager.getKeychainPaymentCodePriv(forAccount: 0)
        
        guard let selfPCInternal = try? PrivatePaymentCode(priv: selfPCPrivData) else {
            return []
        }
        
        var newSendAddresses = [String]()
        for index in range {
            guard
                let recipientPC = try? PaymentCode(with: paymentCode),
                let key = selfPCInternal.ethemeralSendBRKey(to: recipientPC, i: UInt32(index)) else {
                continue
            }
            newSendAddresses.append(key.address!)
        }
        return newSendAddresses
    }
    
    func addressToSend() -> String? {
        let selfPCPrivData = AccountManager.shared.getSelfCPPriv()
        guard let selfPCInternal = try? PrivatePaymentCode(priv: selfPCPrivData) else {
            return nil
        }
        
        guard
            let recipientPC = try? PaymentCode(with: paymentCode),
            let key = selfPCInternal.ethemeralSendBRKey(to: recipientPC, i: UInt32(firstUnusedIndex)) else {
            return nil
        }
        return key.address
    }
    
    mutating func incrementFirstUnusedIndex() {
        firstUnusedIndex += 1
    }

    func generateReceiveAddresses(range: CountableRange<Int>) -> [String] {
        var seedPhrase: String!
#if TEST_SUITE
        seedPhrase = TestConstants.seedPhrase
#else
        seedPhrase = AccountManager.shared.getMnemonic()!
#endif
        let seed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil)!
        
        let currentAccount = AccountManager.shared.currentAccountNumber
        let contactPC = try! PaymentCode(with: paymentCode)
        let pcPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: currentAccount, fromSeed: seed)
        
        guard let pcInternal = try? PrivatePaymentCode(priv: pcPrivData) else {
            return []
        }
        
        //receive addresses
        var addresses = [String]()
        for i in range {
            let receiveAddress = pcInternal.ethemeralReceiveBRKey(from: contactPC, i: UInt32(i))?.address
            addresses.append(receiveAddress!)
        }
        return addresses
    }
    
    func getConnectedAddress(for transaction: Transaction) -> String? {
        let outputsAddresses = transaction.outputAddresses
        let txSet = Set(outputsAddresses)
        let pregenSet = Set(receiveAddresses)
        let pregenSendSet = Set(sendAddresses)
        
        let intersection = txSet.intersection(pregenSet)
        if let receive = intersection.first {
            return receive
        }
        
        let sendIntersection = txSet.intersection(pregenSendSet)
        if let send = sendIntersection.first {
            return send
        }
        
        return nil
    }
    
    func getConnectedReceiveAddress(for transaction: BRTransaction) -> String? {
        let outputsAddresses = transaction.outputAddresses.flatMap { $0 as? String }
        let txSet = Set(outputsAddresses)
        let pregenSet = Set(receiveAddresses)
        
        let intersection = txSet.intersection(pregenSet)
        if let receive = intersection.first {
            return receive
        }
        
        return nil
    }
    
    func getConnectedSendAddress(for transaction: BRTransaction) -> String? {
        let outputsAddresses = transaction.outputAddresses.flatMap { $0 as? String }
        let txSet = Set(outputsAddresses)
        let pregenSet = Set(sendAddresses)
        
        let intersection = txSet.intersection(pregenSet)
        if let send = intersection.first {
            return send
        }
        
        return nil
    }
    
   func getNewPregeneratedReceiveAddresses(forReceivingAddress address: String) -> [String] {
        let constant = Int(PaymentCodeContact.pregenCount / 4)
        guard let index = receiveAddresses.index(of: address), index < receiveAddresses.count - constant else {
            let newReceiveAddresses = generateReceiveAddresses(range: receiveAddresses.count..<receiveAddresses.count+3*constant)
            return newReceiveAddresses
        }
        return []
    }
    
    func getNewPregeneratedSendAddresses(forSendAddress address: String) -> [String] {
        let constant = Int(PaymentCodeContact.pregenCount / 4)
        guard let index = sendAddresses.index(of: address), index < sendAddresses.count - constant else {
            let newReceiveAddresses = generateSendAddresses(range: sendAddresses.count..<sendAddresses.count+3*constant)
            return newReceiveAddresses
        }
        return []
    }
}

// MARK: - ContactDisplayable

extension PaymentCodeContactProtocol {
    
    var sharingString: String {
        return "billion://contact/\(paymentCode)"
    }
    
}
