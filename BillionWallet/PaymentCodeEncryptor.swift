//
//  PaymentCodeEncryptor.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum PaymentCodeEncryptionError: LocalizedError {
    case keyGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .keyGenerationFailed:
            return "Failed to generate encryption keys. Choose another index."
        }
    }
}

class PaymentCodeEncryptor {
    private let version: Int = 0x01
    private let chainIdx: UInt32 = 0x7fffffff   // 2^31 - 1
    private let config: ECIESConfig
    private let sequence: BIP44Sequence = BIP44Sequence()
    
    private let selfPC: PrivatePaymentCode
    private let otherPC: PaymentCode
    
    private var cache: PCKeyCacheService
    
    private var selfIndex: UInt32 = 1
    private var otherIndex: UInt32 = 1
    private var ecies: ECIES!
    
    init(_ selfPrivPC: PrivatePaymentCode,
         _ otherPC: PaymentCode,
         cache: PCKeyCacheService,
         config: ECIESConfig) {
        
        self.selfPC = selfPrivPC
        self.otherPC = otherPC
        self.cache = cache
        self.config = config
    }
    
    private func createEncryptionKeys(_ i: UInt32, _ j: UInt32) throws -> (priv: Priv, pub: Pub) {
        let a0 = sequence.privateKey(0,
                                     inSubchain: chainIdx,
                                     forPaymentCodePriv: selfPC.xPriv.data)
        let ai = sequence.privateKey(i,
                                     inSubchain: chainIdx,
                                     forPaymentCodePriv: selfPC.xPriv.data)
        let B0 = sequence.publicKey(0,
                                    inSubchain: chainIdx,
                                    forPaymentCodePub: otherPC.xPub.data)
        let Bj = sequence.publicKey(j,
                                    inSubchain: chainIdx,
                                    forPaymentCodePub: otherPC.xPub.data)
        guard let ABj = BIP47.ephemeralPubKey(priv: Priv(data: a0), pub: Pub(data: Bj)),
            let bai = BIP47.ephemeralPrivKey(priv: Priv(data: ai), pub: Pub(data: B0))
            else {
                // Need to choose another index
                throw PaymentCodeEncryptionError.keyGenerationFailed
        }
        return (priv: bai, pub: ABj)
    }
    
    func performKeyRotation() {
        if selfIndex <= otherIndex {
            selfIndex += 1
        } else {
            otherIndex += 1
        }
    }
    
    func prepareKeys() {
        if !prepareKeys(selfIndex, otherIndex) {
            performKeyRotation()
        }
    }
    
    func prepareKeys(_ i: UInt32, _ j: UInt32) -> Bool {
        let key = cache.getKey(selfPC: selfPC.xPub.data,
                               otherPC: otherPC.xPub.data,
                               selfIndex: i,
                               otherIndex: j)
        if let c = cache.getCache(forKey: key) {
            ecies = ECIES(c)
        } else {
            do {
                let keys = try createEncryptionKeys(i, j)
                ecies = ECIES(with: config)
                try ecies.setUp(priv: keys.priv, pub: keys.pub)
                let c = PCKeyCache(ecies)!
                cache.storeCache(c, forKey: key)
            } catch PaymentCodeEncryptionError.keyGenerationFailed {
                return false
            } catch let error {
                Logger.error("\(error)")
                fatalError("Undefined behaviour")
            }
        }
        return true
    }
    
    func encrypt(_ message: Data) throws -> MessageEnvelope {
        var keysPrepared = prepareKeys(selfIndex, otherIndex)
        var retryCount = 3
        while !keysPrepared && retryCount > 0 {
            performKeyRotation()
            keysPrepared = prepareKeys(selfIndex, otherIndex)
            retryCount -= 1
        }
        if !keysPrepared && retryCount == 0 {
            // Chance is (1/2^127)^3
            fatalError("This should not happen in normal situation")
        }
        
        let result = try ecies.encrypt(message)
        let envelope = MessageEnvelope(selfIndex, otherIndex, result.c, result.d)
        return envelope
    }
    
    func decrypt(_ envelope: MessageEnvelope) throws -> Data {
        let i = envelope.i
        let j = envelope.j
        let cipher = envelope.c
        let mac = envelope.d
        
        let keysPrepared = prepareKeys(j, i)
        if !keysPrepared {
            throw PaymentCodeEncryptionError.keyGenerationFailed
        }
        
        let result = try ecies.decrypt(cipher, mac: mac)
        if selfIndex < i || otherIndex < j {
            selfIndex = i
            otherIndex = j
        }
        return result
    }
}
