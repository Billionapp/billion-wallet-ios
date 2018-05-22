//
//  BreadWallet.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct Table: LocalizedError {
    init() { }
    
    var errorDescription: String? {
        return "(┛◉Д◉)┛彡┻━┻"
    }
}

extension UInt256S: Hashable {
    var hashValue: Int {
        return data.hashValue
    }
    
    static func ==(lhs: UInt256S, rhs: UInt256S) -> Bool {
        return lhs.data == rhs.data
    }
}

class BreadWallet: BWallet {
    private let brWallet: BRWallet
    
    init(brWallet: BRWallet) {
        self.brWallet = brWallet
    }
    
    var balance: UInt64 {
        return brWallet.balance
    }
    
    var minOutputAmount: UInt64 {
        return brWallet.minOutputAmount
    }
    
    var receiveAddress: String {
        return brWallet.receiveAddress!
    }
    
    var changeAddress: String {
        return brWallet.changeAddress!
    }
    
    var allReceiveAddresses: [String] {
        return brWallet.allReceiveAddresses.flatMap { $0 as? String }
    }
    
    var allChangeAddresses: Set<String> {
        return brWallet.allChangeAddresses
    }
    
    func containsAddress(_ address: String) -> Bool {
        return brWallet.containsAddress(address)
    }
    
    func privateKey(forAddress address: String) -> String? {
        return brWallet.privateKey(forAddress: address)
    }
    
    var unspentOutputs: [BRUTXO] {
        return brWallet.unspentOutputs.flatMap({ v -> BRUTXO in
            var brutxo = BRUTXO()
            (v as! NSValue).getValue(&brutxo)
            return brutxo
        })
    }
    
    var allTransactions: [BRTransaction] {
        return brWallet.allTransactions.flatMap { $0 as? BRTransaction }
    }
    
    func register(transaction: BRTransaction) throws {
        let success = brWallet.register(transaction)
        if !success {
            throw Table()
        }
    }
    
    func transaction(forHash uint256: UInt256) -> BRTransaction? {
        return brWallet.transaction(forHash: uint256)
    }
    
    func transactionIsValid(_ transaction: BRTransaction) -> Bool {
        return brWallet.transactionIsValid(transaction)
    }
    
    func transactionIsPending(_ transaction: BRTransaction) -> Bool {
        return brWallet.transactionIsPending(transaction)
    }
    
    func transactionIsVerified(_ transaction: BRTransaction) -> Bool {
        return brWallet.transactionIsVerified(transaction)
    }
    
    func getAllTxs() -> [UInt256S : BRTransaction] {
        let allTx = brWallet.getAllTxs().flatMap({ (kv) -> (key: UInt256S, value: BRTransaction) in
            var key = UInt256()
            kv.key.getValue(&key)
            return (key: UInt256S(key), value: kv.value)
        })
        var allTxDict: [UInt256S : BRTransaction] = [:]
        for kv in allTx {
            allTxDict[kv.key] = kv.value
        }
        return allTxDict
    }
    
    func amountReceived(from transaction: BRTransaction) -> UInt64 {
        return brWallet.amountReceived(from: transaction)
    }
    
    func amountSent(by transaction: BRTransaction) -> UInt64 {
        return brWallet.amountSent(by: transaction)
    }
    
    func fee(for transaction: BRTransaction) -> UInt64 {
        return brWallet.fee(for: transaction)
    }
    
    func balance(after transaction: BRTransaction) -> UInt64 {
        return brWallet.balance(after: transaction)
    }
    
    func addAddressesAfterNotificationTxImediately(_ txBlockHeight: UInt32) {
        return brWallet.addAddresses(afterNotificationTxImediately: txBlockHeight)
    }
    
    func partnerAddress(from array: [String]) -> String? {
        return brWallet.partnerAddress(from: array)
    }
}
