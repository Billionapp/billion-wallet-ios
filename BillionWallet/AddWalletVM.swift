//
//  AddWalletVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AddWalletVMDelegate: class {
    func phraseDidSet(phrase: String)
    func phraseDidRecoved()
}

class AddWalletVM {
    
    var seedPhrase: String? {
        didSet {
            if let seed = seedPhrase {
                delegate?.phraseDidSet(phrase: seed)
            }
        }
    }
    
    var recoveredSeed: String?
    
    weak var delegate: AddWalletVMDelegate!
    weak var walletProvider: WalletProvider!
    weak var icloudProvider: ICloud!
    weak var defaultsProvider: Defaults!
    weak var accountProvider: AccountManager!
    weak var contactsProvider: ContactsProvider!
    weak var pcProvider: PaymentCodesProvider!
    weak var taskQueueProvider: TaskQueueProvider!
    
    init(walletProvider:WalletProvider,
         icloudProvider: ICloud,
         defaultsProvider: Defaults,
         accountProvider: AccountManager,
         pcProvider: PaymentCodesProvider,
         contactsProvider: ContactsProvider,
         taskQueueProvider: TaskQueueProvider) {
        
        self.walletProvider = walletProvider
        self.icloudProvider = icloudProvider
        self.defaultsProvider = defaultsProvider
        self.accountProvider = accountProvider
        self.contactsProvider = contactsProvider
        self.pcProvider = pcProvider
        self.taskQueueProvider = taskQueueProvider
        taskQueueProvider.start()
    }
    
    private func prepareString(_ str: String) -> String {
        let components = str.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    func generateWallet() {
        self.setFirstEnterDateIfNeeded()
        
        guard let provider = self.walletProvider else { return }
        self.seedPhrase = provider.generateRandomSeed()
        if let seed = self.seedPhrase {
            
            do {
                try self.pcProvider.generatePaymentCodes(seedPhrase: seed)
            } catch {
                fatalError("PC generation failed with: \(error.localizedDescription)")
            }
            self.defaultsProvider.isWalletJustCreated = true
            
            self.taskQueueProvider.addOperation(type: .register)
            self.taskQueueProvider.addOperation(type: .pushConfig)
        }
    }
    
    fileprivate func setFirstEnterDateIfNeeded() {
        if defaultsProvider.firstLaunchDate == nil {
            defaultsProvider.firstLaunchDate = Date()
        }
    }

}

// MARK: - InputTextViewDelegate
extension AddWalletVM: InputTextViewDelegate {
    
    func didChange(value: String) {
        recoveredSeed = value.lowercased()
    }
    
    func didConfirm() {
        self.setFirstEnterDateIfNeeded()
        
        guard let seed = self.recoveredSeed else { return }
        let preparedseed = self.prepareString(seed)
        do {
            try self.walletProvider.recoverWallet(withPhrase: preparedseed)
            try self.pcProvider.generatePaymentCodes(seedPhrase: preparedseed)
            self.delegate?.phraseDidRecoved()
            self.taskQueueProvider.addOperation(type: .register)
            self.taskQueueProvider.addOperation(type: .pushConfig)
        } catch RecoverWalletError.invalidPhraseError {
            self.showErrorPopupWithString(title: RecoverWalletError.invalidPhraseError.localizedDescription)
        } catch RecoverWalletError.emptyMnemonicError {
            self.showErrorPopupWithString(title: RecoverWalletError.emptyMnemonicError.localizedDescription)
        } catch RecoverWalletError.phraseNormalizationError {
            self.showErrorPopupWithString(title: RecoverWalletError.phraseNormalizationError.localizedDescription)
        } catch {
            self.showErrorPopupWithString(title: RecoverWalletError.unknownError.localizedDescription)
        }
    }
    
    func showErrorPopupWithString(title: String) {
        let popup = PopupView(type: .cancel, labelString: title)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
}
