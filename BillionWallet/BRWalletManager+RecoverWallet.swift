//
//  BRWalletManager+RecoverWallet.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

public enum RecoverWalletError: Error  {
    case emptyMnemonicError
    case phraseNormalizationError
    case invalidPhraseError
    case unknownError
}

extension RecoverWalletError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .emptyMnemonicError:
            return NSLocalizedString("Phrase is empty", comment: "")
        case .phraseNormalizationError:
            return NSLocalizedString("Phrase is wrong", comment: "")
        case .invalidPhraseError:
            return NSLocalizedString("Your phrase is invalid", comment: "")
        case .unknownError:
            return NSLocalizedString("Unknown Error", comment: "")
        }
    }
}

extension BRWalletManager {
    func recoverWallet(withPhrase phrase: String) throws {
        guard let mnem = self.mnemonic else { throw RecoverWalletError.emptyMnemonicError }
        guard let phrase = mnem.normalizePhrase(phrase) else { throw RecoverWalletError.phraseNormalizationError }
        
        let words = phrase.components(separatedBy: .whitespacesAndNewlines)
        for word in words {
            if !mnem.wordIsValid(word) {
                throw RecoverWalletError.invalidPhraseError
            }
        }
        self.seedPhrase = phrase
    }
}
