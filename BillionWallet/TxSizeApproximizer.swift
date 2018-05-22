//
//  TxSizeApproximizer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxSizeApproximizer {
    func txSizeFor(inputCount: UInt64, outputCount: UInt64) -> Int
}

class StandardTxSizeApproximizer: TxSizeApproximizer {
    /// Typical input size (P2PKH unlock script)
    ///
    ///     TxOutHash: 32 bytes
    ///     TxOutIndex: 4 bytes
    ///     ScriptLen: VarInt(106) 2 bytes
    ///     Script:
    ///         Signature: 71-73 bytes
    ///         PubKey: 34 bytes
    ///     Sequence: 4 bytes
    let txInputSize = 148
    /// Typical output size (P2PKH lock script)
    ///
    ///     Value: 8 bytes
    ///     ScriptLen: VarInt() 1 byte
    ///     Script:
    ///         OP_DUP OP_HASH160 0x14 {20byte hash} OP_EQUALVERIFY OP_CHECKSIG
    ///         25 bytes
    let txOutputSize = 34
    
    func txSizeFor(inputCount: UInt64, outputCount: UInt64) -> Int {
        let utxoVarIntSize = NSMutableData.size(ofVarInt: inputCount)
        let twoVarIntSize = NSMutableData.size(ofVarInt: outputCount)
        var txSize = 4                              // Version 4 bytes
        txSize += utxoVarIntSize                    // inCount 1-9 bytes
        txSize += txInputSize*Int(inputCount)       // Inputs
        txSize += twoVarIntSize                     // outCount 1-9 bytes
        txSize += txOutputSize*Int(outputCount)     // Outputs
        txSize += 4                                 // lock_time 4 bytes
        
        return txSize
    }
}

class NotificationV1TxSizeApproximizer: TxSizeApproximizer {
    /// Typical input size (P2PKH unlock script)
    ///
    ///     TxOutHash: 32 bytes
    ///     TxOutIndex: 4 bytes
    ///     ScriptLen: VarInt(106) 1 byte
    ///     Script:
    ///         Signature: 71-73 bytes
    ///         PubKey: 34 bytes
    ///     Sequence: 4 bytes
    let txInputSize = 148
    /// Typical output size (P2PKH lock script)
    ///
    ///     Value: 8 bytes
    ///     ScriptLen: VarInt(25) 1 byte
    ///     Script:
    ///         OP_DUP OP_HASH160 0x14 {20byte hash} OP_EQUALVERIFY OP_CHECKSIG
    ///         25 bytes
    let txOutputSize = 34
    /// Typical OP_RETURN output size
    ///
    ///     Value: 8 bytes
    ///     ScriptLen: VarInt(83) 1 byte
    ///     Script:
    ///         OP_RETURN OP_PUSHDATA1 0x50 {80 byte data}
    let opReturnOutputSize = 92
    
    func txSizeFor(inputCount: UInt64, outputCount: UInt64) -> Int {
        let utxoVarIntSize = NSMutableData.size(ofVarInt: inputCount)
        let twoVarIntSize = NSMutableData.size(ofVarInt: outputCount+2) // + Notification address and OP_RETURN
        var txSize = 4                              // Version 4 bytes
        txSize += utxoVarIntSize                    // inCount 1-9 bytes
        txSize += txInputSize*Int(inputCount)       // Inputs
        txSize += twoVarIntSize                     // outCount 1-9 bytes
        txSize += txOutputSize*Int(outputCount+1)     // Outputs
        txSize += opReturnOutputSize
        txSize += 4                                 // lock_time 4 bytes
        
        return txSize
    }
}
