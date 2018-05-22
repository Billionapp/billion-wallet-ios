//
//  BreadWalletManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BreadWalletManager: BWalletManager {
    private let brWalletManager: BRWalletManager
    
    init(brWalletManager: BRWalletManager) {
        self.brWalletManager = brWalletManager
    }
    
    var seedPhrase: String? {
        return brWalletManager.seedPhrase
    }
    
    var noWallet: Bool {
        return brWalletManager.noWallet
    }
    
    var seedCreationTime: TimeInterval {
        return brWalletManager.seedCreationTime
    }
    
    var isTestnet: Bool {
        return brWalletManager.isTestnet
    }
    
    func generateRandomSeed() -> String? {
        return brWalletManager.generateRandomSeed()
    }
    
    func recoverWallet(withPhrase phrase: String) throws {
        return try brWalletManager.recoverWallet(withPhrase: phrase)
    }

}
