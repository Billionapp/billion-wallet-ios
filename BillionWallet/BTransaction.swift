//
//  BTransaction.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BTransaction {
    var inputAddresses: [String] { get }
    var inputHashes: [UInt256S] { get }
    var inputIndexes: [UInt] { get }
    var inputSignatures:  [NSData]? { get }
    var outputAmounts: [UInt64] { get }
    var outputAddresses: [String] { get }
    var outputScripts: [Data] { get }
    var txId: String { get }
    var txHash: UInt256S { get }
    var blockHeight: UInt32 { get }
    var dateTimestamp: Date { get }
    var size: Int { get }
    var isSigned: Bool { get }
    var timestamp: TimeInterval { get }
    
    func addInput(hash: UInt256S, index: UInt, script: Data?)
    func addOutput(address: String, amount: UInt64)
    func addOutput(script: Data, amount: UInt64)
    func shuffleOutputOrder()
    func signWithPrivateKeys(_ privateKeys: [String]) -> Bool
}
