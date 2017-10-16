//
//  WalletProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class WalletProvider {
    
    let manager: BRWalletManager
    let peerManager: BRPeerManager
    
    init(manager: BRWalletManager, peerManager: BRPeerManager) {
        self.manager = manager
        self.peerManager = peerManager
    }
    
    func getSeedData() -> Data? {
        guard let seedPhrase = BRWalletManager.getMnemonicKeychainString() else {
            return nil
        }
        return BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil)
    }
}
