//
//  PaymentCode.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28.06.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

public enum PaymentCodeError: LocalizedError {
    case unsupportedVersion
    case binaryDeserialization
    case invalidPaymentCode(String)
    case keyNotMatchesInput
    
    public var errorDescription: String? {
        switch self {
        case .unsupportedVersion:
            return NSLocalizedString("Payment code version is unsupported", comment: "")
        case .invalidPaymentCode(let pc):
            return String(format: NSLocalizedString("Payment code %@ is invalid", comment: ""), pc)
        case .binaryDeserialization:
            return NSLocalizedString("Binary deserialization failed", comment: "")
        case .keyNotMatchesInput:
            return NSLocalizedString("Key not matches 0th input of transaction", comment: "")
        }
    }
}

/// Deserialize binary represenatation of PC
///
/// - Parameter data: PC binary data
/// - Returns: PC as extended public key
fileprivate func binaryDeserialize(_ data: Data) -> XPub {
    let d = data.subdata(in: Range<Int>(2...66))
    return XPub(d)
}

/// Simply xor data to mask/unmask payment code
///
/// - Parameters:
///   - data: payment code or masked payment code
///   - blindingFactor: blinding factor mask
/// - Returns: payment code binary data or masked payment code
fileprivate func xorData(_ data: Data, with blindingFactor: XPriv) -> Data {
    var result = Data()
    result.append(UInt8(0x00))
    result.append(contentsOf: blindingFactor.data)
    
    for i in 0..<result.count {
        result[i] ^= data[i]
    }
    return result
}

/// Given payload create OP_RETURN script for transaction
///
/// - Parameter payload: 80-byte payload
/// - Returns: OP_RETURN transaction script
func opReturnScript(with payload: Data) -> Data {
    var script = Data()
    script.append(0x6a as UInt8) // OP_RETURN
    script.append(0x4c as UInt8) // OP_PUSHDATA1
    script.append(0x50 as UInt8) // length 80
    script.append(payload)
    return script
}

class PaymentCode {
    enum NetworkPrefix: UInt8 {
        case main = 0x47
        case test = 0x50
    }
    
    var version: UInt8 = 0x01
    var networkPrefix: NetworkPrefix = .main
    
    /// Payment code public key
    let xPub: XPub
    
    /// Public key for Notification address (PC/0)
    lazy var notificationKey: Pub = {
        let pub0Data = BIP44Sequence().publicKey(0, forPaymentCodePub: xPub.data)
        return Pub(data: pub0Data)
    }()
    
    /// Binary serialized
    var binaryForm: Data {
        return binarySerialize(xPub)
    }
    
    /// Payment code identifier. Set version to 0x02 if using this.
    var identifier: Pub? {
        guard version >= 0x02 else {
            return nil
        }
        return BIP47.paymentCodeIdentifier(with: binaryForm)
    }
    
    /// String representation for sharing
    var serializedString: String {
        var d = Data()
        d.append(networkPrefix.rawValue)
        d.append(binaryForm)

        return String.base58check(with: d)
    }
    
    /// false for unowned payment codes
    var isInternal: Bool { return false }
    
    init() { xPub = XPub(Data(repeating: 0x00, count: 65)) }
    
    /// Create unowned PC capable only to create public keys
    ///
    /// - Parameter publicKey: Extended public key for PC
    init(_ publicKey: XPub) {
        xPub = publicKey
    }
    
    /// Convenience initializer for xPub packed in Data
    ///
    /// - Parameter publicData: Data struct containing xPub
    convenience init(pub publicData: Data) throws {
        guard publicData.count == 65 else {
            throw PaymentCodeError.binaryDeserialization
        }
        
        let pub = XPub(publicData)
        self.init(pub)
    }
    
    /// Convenience initializer for binary represented PaymentCode
    ///
    /// - Parameter binaryRepresentation: exactly 80 bytes of binary represented payment code
    convenience init(with binaryRepresentation: Data) throws {
        guard binaryRepresentation.count == 80 else {
            throw PaymentCodeError.binaryDeserialization
        }
        guard PaymentCode.supportedVersions.contains(binaryRepresentation[0]) else {
            throw PaymentCodeError.unsupportedVersion
        }
        
        let d = binaryRepresentation.subdata(in: Range<Int>(2...66))
        try self.init(pub: d)
    }
    
    /// Convenience initializer for string representation, probably received from friend
    ///
    /// - Parameter serializedString: String representation of PC
    convenience init(with serializedString: String) throws {
        guard let data = serializedString.base58checkAsData else {
            throw PaymentCodeError.invalidPaymentCode(serializedString)
        }
        
        guard data.count == 81 && NetworkPrefix(rawValue: data[0]) != nil else {
            throw PaymentCodeError.invalidPaymentCode(serializedString)
        }
        guard PaymentCode.supportedVersions.contains(data[1]) else {
            throw PaymentCodeError.unsupportedVersion
        }
        
        let d = data.subdata(in: Range<Int>(3...67))
        try self.init(pub: d)
        networkPrefix = NetworkPrefix(rawValue: data[0])!
    }
    
    /// Serialize PC represented by xPub
    ///
    /// - Parameter xpub: xPub representing PC
    /// - Returns: Binary serialized representation
    fileprivate func binarySerialize(_ xpub: XPub) -> Data {
        var d = Data()
        d.append(version)                           // version: 1 or 2
        d.append(0x00 as UInt8)                     // bitbessage off
        d.append(xpub.data)
        d.append(Data(repeating: 0x00, count: 13))  // Padding
        return d
    }
    
    fileprivate static let supportedVersions: [UInt8] = [0x01, 0x02]
    
    /// Creates masked binary representation for PC with blinding factor
    ///
    /// - Parameter blindingFactor: Binary mask created with DH
    /// - Returns: Masked binary representation
    func maskedBinary(with blindingFactor: XPriv) -> Data {
        let masked = xorData(xPub.data, with: blindingFactor)
        return binarySerialize(XPub(masked))
    }
    
    /// Creates a notification payload, ready to be inserted into OP_RETURN script
    ///
    /// - Parameters:
    ///   - paymentCode: Recepient payment code used to create a mask
    ///   - outpoint: Designated outpoint of the notification transaction
    ///   - key: Designated Private key of the notification transaction
    /// - Returns: Notification payload
    func notificationPayload(for paymentCode: PaymentCode, outpoint: TXOutpointS, key: Priv) throws -> Data {
        let bobNotifKey = paymentCode.notificationKey
        
        let secretPoint = BIP47.secretPoint(priv: key, pub: bobNotifKey)
        let blindingFactor = try BIP47.blindingFactor(secretPoint, outpoint: outpoint)
        let payload = maskedBinary(with: blindingFactor)
        return payload
    }
    
    /// Creates a notification OP_RETURN script
    ///
    /// - Parameters:
    ///   - paymentCode: Recepient payment code used to create a mask
    ///   - outpoint: Designated outpoint of the notification transaction
    ///   - key: Designated Private key of the notification transaction
    /// - Returns: Notification script
    func notificationOpReturnScript(for paymentCode: PaymentCode, outpoint: TXOutpointS, key: Priv) throws -> Data {
        let payload = try notificationPayload(for: paymentCode, outpoint: outpoint, key: key)
        let script = opReturnScript(with: payload)
        return script
    }
    
    /// Create change 1of2 multisig script with the specified change public key
    /// Supported only in version 0x02
    ///
    /// OP_1 <Bob's payment code identifier> <change address pubkey> OP_2 OP_CHECKMULTISIG
    ///
    /// - Parameter changeKey: public key of change address
    /// - Returns: script data, ready to be applied to transaction. nil on version mismatch
    func notificationChangeScript(changeKey: Pub) -> Data? {
        var data = Data([0x51])         // OP_1
        guard let identifier = identifier else {
            return nil
        }
        data.append(identifier.data)    // This payment code identifier
        data.append(changeKey.data)     // Change public key
        data.append(0x52 as UInt8)      // OP_2
        data.append(0xae as UInt8)      // OP_CHECKMULTISIG
        return data
    }
}


class PrivatePaymentCode: PaymentCode {
    
    /// Payment code private key. nil for unowned payment codes.
    var xPriv: XPriv
    
    override var isInternal: Bool { return true }
    
    /// Private key for Notification address (PC/0)
    var notificationPrivateKey: Priv {
        let priv0Data = BIP44Sequence().privateKey(0, forPaymentCodePriv: xPriv.data)
        return Priv(data: priv0Data)
    }
    
    /// Create owned PC capable to create private keys
    ///
    /// - Parameter privateKey: Extended private key for PC
    init(_ privateKey: XPriv) {
        xPriv = privateKey
        
        super.init(privateKey.pub)
    }
    
    /// Convenience crash safe initializer for xPriv packed in Data
    ///
    /// - Parameter privateData: Data struct containing xPriv
    convenience init(priv privateData: Data) throws {
        let priv = try XPriv(privateData)
        self.init(priv)
    }
    
    /// Extract the payment code from notification transaction payload
    ///
    /// - Parameters:
    ///   - maskedPaymentCode: Notification transaction payload
    ///   - oupoint: Designated outpoint of the notification transaction
    ///   - key: Designated public key
    /// - Returns: Extracted payment code
    func unmaskPaymentCode(_ maskedPaymentCode: Data, oupoint: TXOutpointS, key: Pub) throws -> PaymentCode {
        let aliceNotifKey = self.notificationPrivateKey
        
        let secretPoint = BIP47.secretPoint(priv: aliceNotifKey, pub: key)
        let blindingFactor = try BIP47.blindingFactor(secretPoint, outpoint: oupoint)
        let masked = maskedPaymentCode.subdata(in: Range<Int>(2...66))
        let paymentCodeData = xorData(masked, with: blindingFactor)
        
        // can fail only in case of maskedPaymentCode has invalid size
        return try PaymentCode(pub: paymentCodeData)
    }
    
    /// Creates a new ephemeral public key for the recipient represented by payment code (Alice -> Bob)
    ///
    /// - Parameters:
    ///   - paymentCode: Recipient's payment code
    ///   - index: Index of a key to generate
    /// - Returns: i-th ephemeral public key (ABi)
    func ephemeralSendKey(to paymentCode: PaymentCode, i index: UInt32) -> Pub? {
        // sender (self) is A, receiver is B
        let a0Data = BIP44Sequence().privateKey(0, forPaymentCodePriv: xPriv.data)
        let a0 = Priv(data: a0Data)
        let BiData = BIP44Sequence().publicKey(index, forPaymentCodePub: paymentCode.xPub.data)
        let Bi = Pub(data: BiData)
        
        return BIP47.ephemeralPubKey(priv: a0, pub: Bi)
    }
    
    /// Creates a new ephemeral private key to receive from sender represented by payment code (Bob -> Alice)
    ///
    /// - Parameters:
    ///   - paymentCode: Sender's payment code
    ///   - index: Index of a key to generate
    /// - Returns: i-th ephemeral private key (bai)
    func ephemeralReceiveKey(from paymentCode: PaymentCode, i index: UInt32) -> Priv? {
        
        // sender is A, receiver (self) is B
        let A0Data = BIP44Sequence().publicKey(0, forPaymentCodePub: paymentCode.xPub.data)
        let A0 = Pub(data: A0Data)
        let biData = BIP44Sequence().privateKey(index, forPaymentCodePriv: xPriv.data)
        let bi = Priv(data: biData)
        
        return BIP47.ephemeralPrivKey(priv: bi, pub: A0)
    }
    
    /// Creates a new ephemeral public key to receive from sender represented by payment code (Bob -> Alice)
    ///
    /// - Parameters:
    ///   - paymentCode: Sender's payment code
    ///   - index: Index of a key to generate
    /// - Returns: i-th ephemeral public key
    func ephemeralReceivePubKey(from paymentCode: PaymentCode, i index: UInt32) -> Pub? {
        guard let priv = ephemeralReceiveKey(from: paymentCode, i: index) else {
            return nil
        }
        return privToPub(priv)
    }
    
    private func privToPub(_ priv: Priv) -> Pub {
        let point = Secp256k1.pointGen(priv.uint256)
        return Pub(point)
    }
}

enum PrivatePaymentCodeError: Error {
    case noScript
    case noPubData
    case noOutputScripts
    case noMaskedCode
    case keyNotMatchesTransaction
}
