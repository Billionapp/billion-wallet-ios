//
//  BRWalletManager + RestoreWallet.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension BRWalletManager {
    
    func deleteWallet(withSeed phrase: String, success: () -> Void, failure: (Error) -> Void) {
        guard let seq = self.sequence else {
            failure(DeleteError.foundNil)
            return
        }
        guard let mnem = self.mnemonic else {
            failure(DeleteError.foundNil)
            return
        }
        
        let mpk = self.masterPublicKey
        if seq.masterPublicKey(fromSeed: mnem.deriveKey(fromPhrase: phrase, withPassphrase: nil)) == mpk {
            self.seedPhrase = nil
            AccountManager.shared.clearAccountKeychain()
            success()
        } else {
            failure(DeleteError.invalidPhrase)
        }
    }
}

enum DeleteError: Error {
    case foundNil
    case invalidPhrase
}

extension DeleteError: LocalizedError {
    var description: String {
        switch self {
        case .foundNil:
            return NSLocalizedString("Unexpected nil", comment: "")
        case .invalidPhrase:
            return NSLocalizedString("Phrase is invalid", comment: "")
        }
    }
}
