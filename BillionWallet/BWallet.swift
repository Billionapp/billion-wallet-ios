//
//  Wallet.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BWallet: class {
    var balance: UInt64 { get }
    var minOutputAmount: UInt64 { get }
 
    // MARK: Addresses
    var receiveAddress: String { get }
    var changeAddress: String { get }
    
    var allReceiveAddresses: [String] { get }
    var allChangeAddresses: Set<String> { get }
    
    func containsAddress(_ address: String) -> Bool
    func privateKey(forAddress address: String) -> String?
    
    // MARK: Transactions
    var unspentOutputs: [BRUTXO] { get }
    var allTransactions: [BRTransaction] { get }
    
    func register(transaction: BRTransaction) throws
    
    func transaction(forHash uint256: UInt256) -> BRTransaction?
    func transactionIsValid(_ transaction: BRTransaction) -> Bool
    func transactionIsPending(_ transaction: BRTransaction) -> Bool
    func transactionIsVerified(_ transaction: BRTransaction) -> Bool
    func getAllTxs() -> [UInt256S: BRTransaction]
    
    // MARK: Transaction data
    func amountReceived(from transaction: BRTransaction) -> UInt64
    func amountSent(by transaction: BRTransaction) -> UInt64
    func fee(for transaction: BRTransaction) -> UInt64
    func balance(after transaction: BRTransaction) -> UInt64
    
    // MARK: Other functions
    func addAddressesAfterNotificationTxImediately(_ txBlockHeight: UInt32)
    func partnerAddress(from array: [String]) -> String?
}
