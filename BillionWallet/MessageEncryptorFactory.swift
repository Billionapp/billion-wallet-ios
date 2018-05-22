//
//  MessageEncryptorFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/04/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class MessageEncryptorFactory {
    
    func create(alicePC: PrivatePaymentCode, bobPC: PaymentCode) -> MessageEncryptorProtocol {
        let provider = ECIESConfigFactory()
        let archiver = PCKeyCacheBase64Archiver(factory: provider)
        let storage = KeychainDataStorage()
        let keyCache = ChatKeysCache(archiver: archiver, secureStorage: storage)
        let encryptor = PaymentCodeEncryptor(alicePC, bobPC, cache: keyCache, config: provider.genECIESConfig(identifier: .cryptoSwift))
        let messageCryptor = MessageCryptor(encryptor: encryptor)
        return messageCryptor
    }

}
