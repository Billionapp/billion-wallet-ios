//
//  PaymentCodeEncryption.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.07.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct PaymentCodeEncryption {
    private let version: Int = 0x01
    private let chainIdx: UInt32 = 0x7fffffff   // 2^31 - 1
    private let provider: ECIESConfigProvider = Crypto()
    
    var selfPC: PrivatePaymentCode
    var otherPC: PaymentCode?
    
    var cache: ChatKeysCache?
    
    init(_ selfPrivPC: PrivatePaymentCode, _ otherPC: PaymentCode? = nil) {
        self.selfPC = selfPrivPC
        self.otherPC = otherPC
    }
    
    // FIXME: - Mock
    func chooseSelfIndex() -> UInt32 {
        // TODO: Key rotation
        return 0x01
    }
    
    // FIXME: - Mock
    func chooseOtherIndex() -> UInt32 {
        // TODO: Key rotation
        return 0x01
    }
    
    private func createEncryptionKeys(_ i: UInt32, _ j: UInt32) -> ECIES? {
        let a0 = BIP44Sequence().privateKey(0,
                                            inSubchain: chainIdx,
                                            forPaymentCodePriv: selfPC.xPriv.data)
        let ai = BIP44Sequence().privateKey(i,
                                            inSubchain: chainIdx,
                                            forPaymentCodePriv: selfPC.xPriv.data)
        let B0 = BIP44Sequence().publicKey(0,
                                           inSubchain: chainIdx,
                                           forPaymentCodePub: otherPC!.xPub.data)
        let Bj = BIP44Sequence().publicKey(j,
                                           inSubchain: chainIdx,
                                           forPaymentCodePub: otherPC!.xPub.data)
        guard let ABj = BIP47.ephemeralPubKey(priv: Priv(data: a0), pub: Pub(data: Bj)),
            let bai = BIP47.ephemeralPrivKey(priv: Priv(data: ai), pub: Pub(data: B0))
            else {
                // Need to choose another index
                return nil
        }
        let config = provider.genECIESConfig()
        let ecies = ECIES(with: config)
        ecies.setUp(priv: bai, pub: ABj)
        return ecies
    }
    
    mutating func prepareKeys() -> Bool {
        let i = chooseSelfIndex()
        let j = chooseOtherIndex()
        return prepareKeys(i, j)
    }
    
    mutating func prepareKeys(_ i: UInt32, _ j: UInt32) -> Bool {
        guard let otherPC = otherPC else { return false }
        
        if cache != nil && (cache!.selfIndex != i || cache!.otherIndex != j) {
            cache!.selfIndex = i
            cache!.otherIndex = j
            cache!.ecies = createEncryptionKeys(i, j)
        } else if cache == nil {
            cache = ChatKeysCache()
            cache!.selfPCData = selfPC.xPriv.data
            cache!.otherPCData = otherPC.xPub.data
            cache!.selfIndex = i
            cache!.otherIndex = j
            let ecies = createEncryptionKeys(i, j)
            cache!.ecies = ecies
        }
        
        return cache?.isFilled ?? false
    }
    
    mutating func encrypt(_ message: Data) -> MessageEnvelope? {
        let i = chooseSelfIndex()
        let j = chooseOtherIndex()
        
        let keysPrepared = prepareKeys(i, j)
        guard keysPrepared else { return nil }
        guard let ecies = cache!.ecies else { return nil }
        
        let result = ecies.encrypt(message)
        let envelope = MessageEnvelope(i, j, result.c, result.d)
        return envelope
    }
    
    mutating func decrypt(_ envelope: MessageEnvelope) -> Data? {
        let i = envelope.i
        let j = envelope.j
        let cipher = envelope.c
        let mac = envelope.d
        
        let keysPrepared = prepareKeys(j, i)
        guard keysPrepared else { return nil }
        guard let ecies = cache!.ecies else { return nil }
        
        return ecies.decrypt(cipher, mac: mac)
    }
}
