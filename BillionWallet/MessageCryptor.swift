//
//  MessageDecryptor.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class MessageCryptor {
    
    let encryptor: PaymentCodeEncryptor
    
    init(encryptor: PaymentCodeEncryptor) {
        self.encryptor = encryptor
    }
    
}

// MARK: - MessageEncryptorProtocol

extension MessageCryptor: MessageEncryptorProtocol {
    func encrypt(data: Data) throws -> Data {
        let envelope = try encryptor.encrypt(data)
        return envelope.binaryFormat
    }
    
    func decrypt(data: Data) throws -> Data {
        guard let envelope = MessageEnvelope(data: data) else {
            throw MessageDecryptorError.decryptionFailed
        }
        let encrypted = try encryptor.decrypt(envelope)
        return encrypted
    }
}

enum MessageDecryptorError: LocalizedError {
    case decryptionFailed
    
    var errorDescription: String? {
        return "Message decryption failed"
    }
}

