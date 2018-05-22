//
//  PaymentCode+BRKey.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

// MARK: PaymentCode + BRKey
// Methods and properties dependant on BreadWallet classes
extension PaymentCode {
    /// Public notification key in the form of BRKey.
    ///
    /// Useful for accessing from BRWallet
    var notificationBRKey: BRKey? {
        let pub0 = self.notificationKey
        let key = BRKey(publicKey: pub0.data)
        return key
    }
    
    /// Notification address of current payment code
    var notificationAddress: String? {
        return self.notificationBRKey?.address
    }
    
    /// Creates a notification payload, ready to be inserted into OP_RETURN script
    ///
    /// - Parameters:
    ///   - paymentCode: Recepient payment code used to create a mask
    ///   - transaction: Notification transaction
    ///   - key: Designated Private key of the notification transaction
    /// - Returns: Notification payload, nil if key doesn't match transaction input
    func notificationPayload(for paymentCode: PaymentCode, transaction: Transaction, key: Priv) -> Data? {
        guard isKey(key, matches: transaction) else { return nil }
        
        let outpoint = extractDesignatedOutpoint(from: transaction.brTransaction)
        return try? notificationPayload(for: paymentCode, outpoint: outpoint, key: key)
    }
    
    /// Creates a notification OP_RETURN script
    ///
    /// - Parameters:
    ///   - paymentCode: Recepient payment code used to create a mask
    ///   - outpoint: Designated outpoint of the notification transaction
    ///   - key: Designated Private key of the notification transaction
    /// - Returns: Notification script, nil if key doesn't match transaction input
    func notificationOpReturnScript(paymentCode: PaymentCode, transaction: Transaction, key: Priv) -> Data? {
        let payload = notificationPayload(for: paymentCode, transaction: transaction, key: key)
        guard payload != nil else { return nil }
        
        let script = opReturnScript(with: payload!)
        return script
    }
    
    
    /// Check if given private key matches 0th input of transaction
    ///
    /// - Parameters:
    ///   - key: private key to check
    ///   - transaction: transaction to check against
    /// - Returns: true if key matches, false otherwize
    private func isKey(_ key: Priv, matches transaction: Transaction) -> Bool {
        guard let address = transaction.inputAddresses.first as NSString? else { return false }
        guard let keyAddress = BRKey(secret: key.uint256, compressed: true)?.address else { return false }
        if address as String == keyAddress {
            return true
        } else {
            guard let uncompressedAddress = BRKey(secret: key.uint256, compressed: false)?.address else { return false }
            return address as String == uncompressedAddress
        }
    }
}

// MARK: - PrivatePaymentCode + BRKey
// Methods and properties dependant on BreadWallet classes
extension PrivatePaymentCode {
    /// Private notification key in the form of BRKey.
    ///
    /// Useful for accessing from BRWallet
    var notificationPrivateBRKey: BRKey? {
        let priv0 = self.notificationPrivateKey
        let key = BRKey(secret: priv0.uint256, compressed: true)
        return key
    }
    
    /// Creates a new ephemeral send key for the recipient represented by payment code (Alice -> Bob)
    ///
    /// - Parameters:
    ///   - paymentCode: Recipient's payment code
    ///   - index: Index of a key to generate
    /// - Returns: i-th ephemeral public key in the form of BRKey (ABi)
    func ethemeralSendBRKey(to paymentCode: PaymentCode, i index: UInt32) -> BRKey? {
        guard let sendKey = ephemeralSendKey(to: paymentCode, i: index) else { return nil }
        return BRKey(publicKey: sendKey.data)
    }
    
    /// Creates a new ephemeral receive key for the sender represented by payment code (Bob -> Alice)
    ///
    /// - Parameters:
    ///   - paymentCode: Sender's payment code
    ///   - index: Index of a key to generate
    /// - Returns: i-th ephemeral private key in the form of BRKey (bai)
    func ethemeralReceiveBRKey(from paymentCode: PaymentCode, i index: UInt32) -> BRKey? {
        guard let receiveKey = ephemeralReceiveKey(from: paymentCode, i: index) else { return nil }
        return BRKey(secret: receiveKey.uint256, compressed: true)
    }
    
    /// Creates a number of receive keys for the sender represented by payment code (Bob -> Alice)
    ///
    /// - Parameters:
    ///   - paymentCode: Sender's payment code
    ///   - range: Range of key indexes
    /// - Returns: Array of generated keys in form of BRKey
    func ethemeralReceiveBRKeys(from paymentCode: PaymentCode, range: CountableRange<UInt32>) -> [BRKey?] {
        var keys: [BRKey?] = []
        for i in range {
            let key = ethemeralReceiveBRKey(from: paymentCode, i: i)
            keys.append(key)
        }
        return keys
    }
    
    /// Extracts a payment code from the notification transaction
    ///
    /// <b>Warning!</b> If there are several op_return scripts, only first one will be used.
    ///
    /// - Parameter notificationTransaction: Received notification transaction
    /// - Returns: Extracted payment code
    func recoverCode(from notificationTransaction: BRTransaction) throws -> PaymentCode {
        let outpoint = extractDesignatedOutpoint(from: notificationTransaction)
        let inScript = notificationTransaction.inputSignatures.first! as? NSData
        
        guard inScript != nil else { throw PrivatePaymentCodeError.noScript }
        let elems = inScript!.scriptElements()
        let elemsLikePubK = elems.filter { (($0 as? Data)?.count ?? 0) == 33 }
        
        guard let pubData = elemsLikePubK.first as? Data else {
            throw PrivatePaymentCodeError.noPubData
        }
        
        let key = Pub(data: pubData)
        
        guard let outputScripts = notificationTransaction.outputScripts as? [Data] else {
            throw PrivatePaymentCodeError.noOutputScripts
        }
        
        let maskedCodeScript = outputScripts.filter({ isOpReturnScript($0) }).first
        
        guard let maskedCodePayload = maskedCodeScript,
            let maskedCode = getOpReturnPayload(from: maskedCodePayload)
            else { throw PrivatePaymentCodeError.noMaskedCode }
        
        let a = try unmaskPaymentCode(maskedCode, oupoint: outpoint, key: key)
        return a
    }
    
}

/// Recover payload from OP_RETURN transaction script
///
/// - Parameter script: OP_RETURN transaction script
/// - Returns: payload data or nil on fail data
fileprivate func getOpReturnPayload(from script: Data) -> Data? {
    guard isOpReturnScript(script) else { return nil }
    return script.subdata(in: Range<Int>(3..<83))
}

/// Check if given data looks like OP_RETURN transaction script
///
/// - Parameter script: possobly OP_RETURN transaction script
/// - Returns: true if data lookls like valid OP_RETURN script
fileprivate func isOpReturnScript(_ script: Data) -> Bool {
    return script[0] == 0x6a &&
        script[1] == 0x4c &&
        script[2] == 0x50
}

/// Exctract 0th input outpoint from transaction
///
/// - Parameter transaction: bitcoin transaction with inputs
/// - Returns: 0th outpoint structure
fileprivate func extractDesignatedOutpoint(from transaction: BRTransaction) -> TXOutpointS {
    let dIHashValue = transaction.inputHashes.first! as! NSValue
    var dIHash: UInt256 = UInt256()
    dIHashValue.getValue(&dIHash)
    let dIIndex = transaction.inputIndexes.first! as! UInt32
    
    let d = NSMutableData()
    d.append( UInt256S(dIHash).data )
    d.append( dIIndex )
    return TXOutpointS(data: d as Data)
}

