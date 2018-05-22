//
//  Transaction.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct TxInput {
    let outpoint: TXOutpointS
    let scriptSig: Data?
    
    var address: String? {
        return nil
    }
}

struct TxOutput {
    let script: Data
    let amount: UInt64
    
    init(script: Data, amount: UInt64) {
        self.script = script
        self.amount = amount
    }
    
    init?(address: String, amount: UInt64) {
        let data = NSMutableData()
        data.appendScriptPubKey(forAddress: address)
        guard (data as Data).count > 0 else { return nil }
        self.init(script: data as Data, amount: amount)
    }
}

@objc
class Transaction: NSObject {
    
    enum Direction {
        case sent
        case received
        case move
    }
    
    enum Status {
        case pending
        case invalid
        case unverified
        case confirmations(count: UInt32)
        case matured
    }
    
    @objc
    init(brTransaction: BRTransaction, walletProvider: WalletProvider) {
        self.brTransaction = brTransaction
        self.walletProvider = walletProvider
        do {
            let wallet = try walletProvider.getWallet()
            self.received = wallet.amountReceived(from: brTransaction)
            self.sent = wallet.amountSent(by: brTransaction)
            self.fee = wallet.fee(for: brTransaction)
            self.balanceAfterTransaction = wallet.balance(after: brTransaction)
        } catch {
            self.received = 0
            self.sent = 0
            self.fee = 0
            self.balanceAfterTransaction = 0
        }
        self.isNotificationTx = false
        self.direction = (sent == 0) ? .received : .sent
    }
    
    /// If you are creating a new transaction (it's not yet in the blockchain), specify the direction
    convenience init(brTransaction: BRTransaction, walletProvider: WalletProvider, direction: Direction) {
        self.init(brTransaction: brTransaction, walletProvider: walletProvider)
        self.direction = direction
    }
    
    let brTransaction: BRTransaction
    private let walletProvider: WalletProvider
    
    var contact: ContactProtocol?
    var direction: Direction
    var isNotificationTx: Bool
    var received: UInt64
    var sent: UInt64
    var fee: UInt64
    var balanceAfterTransaction: UInt64
    var _isIncomingNotificationTX: Bool? = nil
    
    /// **Unimplemented**
    var outputs: [TxOutput] {
        // FIXME: implement outputs
        return []
    }
    
    /// **Unimplemented**
    var inputs: [TxInput] {
        // FIXME: implement inputs
        return []
    }
    /**
     Amount sent by transaction
     
     For **received** tx:
     sum of all outputs, that are in wallet
     
     For **sent** tx:
     sum of all outputs excluding change
    */
    var amount: UInt64 {
        if direction == .received {
            return received
        } else {
            return UInt64(abs(Int64(received) - Int64(sent) + Int64(fee)))
        }
    }
  
    var txHashString: String {
        return Data(UInt256S(brTransaction.txHash).data.reversed()).hex
    }
    
    var status: Status {
        guard let wallet = try? walletProvider.getWallet() else { return .unverified }
        if confirmations == 0 {
            if !wallet.transactionIsValid(brTransaction) {
                return .invalid
            } else if wallet.transactionIsPending(brTransaction) {
                return .pending
            } else if !wallet.transactionIsVerified(brTransaction) {
                return .unverified
            } else {
                return .confirmations(count: 0)
            }
        } else if confirmations < 6 {
            return .confirmations(count: confirmations)
        }
        
        return .matured
    }
    
    var isReceived: Bool {
        return direction == .received
    }
    
    func publish(using peerMan: BPeerManager, completion: @escaping (Error?) -> Void) {
        peerMan.publishTransaction(self, complition: completion)
    }
    
    var confirmations: UInt32 {
        return (blockHeight > walletProvider.lastBlockHeight) ? 0 : (walletProvider.lastBlockHeight - blockHeight) + 1
    }
}

extension Transaction: BTransaction {
    
    var inputAddresses: [String] {
        return brTransaction.inputAddresses.flatMap { $0 as? String }
    }
    
    var inputHashes: [UInt256S] {
        return brTransaction.inputHashes.flatMap {
            guard let value = $0 as? NSValue else {
                return nil
            }
            var hash256 = UInt256()
            value.getValue(&hash256)
            return UInt256S(hash256)
        }
    }
    
    var inputIndexes: [UInt] {
        return brTransaction.inputIndexes.flatMap { ($0 as? NSNumber)?.uintValue }
    }
    
    var inputSignatures: [NSData]? {
        return brTransaction.inputSignatures as? [NSData]
    }
    
    var outputAmounts: [UInt64] {
        return brTransaction.outputAmounts.map { (($0 as? NSNumber)?.uint64Value) ?? 0 }
    }
    
    var outputAddresses: [String] {
        return brTransaction.outputAddresses.map { ($0 as? String) ?? "" }
    }
    
    var outputScripts: [Data] {
        return brTransaction.outputScripts.flatMap { $0 as? Data }
    }
    
    var txId: String {
        return brTransaction.txId
    }
    
    var txHash: UInt256S {
        return UInt256S(brTransaction.txHash)
    }
    
    var blockHeight: UInt32 {
        return brTransaction.blockHeight
    }
    
    var dateTimestamp: Date {
        if brTransaction.timestamp == 0 {
            return Date()
        } else {
            return Date(timeIntervalSince1970: timestamp)
        }
    }
    
    var size: Int {
        return brTransaction.size
    }
    
    var isSigned: Bool {
        return brTransaction.isSigned
    }
    
    var timestamp: TimeInterval {
        return brTransaction.timestamp + NSTimeIntervalSince1970
    }
    
    func addInput(hash: UInt256S, index: UInt, script: Data?) {
        brTransaction.addInputHash(hash.uint256, index: index, script: script)
    }
    
    func addOutput(address: String, amount: UInt64) {
        brTransaction.addOutputAddress(address, amount: amount)
    }
    
    func addOutput(script: Data, amount: UInt64) {
        brTransaction.addOutputScript(script, amount: amount)
    }
    
    func shuffleOutputOrder() {
        brTransaction.shuffleOutputOrder()
    }
    
    func signWithPrivateKeys(_ privateKeys: [String]) -> Bool {
        return brTransaction.sign(withPrivateKeys: privateKeys)
    }
}

// MARK: - Methods to act like BRTransaction
extension Transaction {
    
    func isIncomingNotificationTx() -> Bool {
        if let isIncTx = _isIncomingNotificationTX {
            return isIncTx
        }
        
        let accountManager = AccountManager()
        if let notificationAddress = accountManager.notificationAddress {
            _isIncomingNotificationTX = outputAddresses.contains(notificationAddress)
        } else {
            _isIncomingNotificationTX = false
        }
        return _isIncomingNotificationTX!
    }
}

// MARK: - PaymentCode overload for Transaction
extension PaymentCode {
    func notificationOpReturnScript(for pc: PaymentCode, transaction: Transaction, key: Priv) -> Data? {
        return self.notificationOpReturnScript(paymentCode: pc, transaction: transaction, key: key)
    }
}
