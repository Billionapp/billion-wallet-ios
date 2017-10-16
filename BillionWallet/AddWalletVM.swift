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
    
    weak var delegate: AddWalletVMDelegate?
    weak var walletProvider: WalletProvider?
    weak var icloudProvider: ICloud?
    weak var defaultsProvider: Defaults?
    weak var accountProvider: AccountManager?
    weak var contactsProvider: ContactsProvider?
    weak var pcProvider: PaymentCodesProvider?
    weak var taskQueueProvider: TaskQueueProvider?
    
    init(walletProvider:WalletProvider, icloudProvider: ICloud, defaultsProvider: Defaults, accountProvider: AccountManager, pcProvider: PaymentCodesProvider, contactsProvider: ContactsProvider, taskQueueProvider: TaskQueueProvider) {
        self.walletProvider = walletProvider
        self.icloudProvider = icloudProvider
        self.defaultsProvider = defaultsProvider
        self.accountProvider = accountProvider
        self.contactsProvider = contactsProvider
        self.pcProvider = pcProvider
        self.taskQueueProvider = taskQueueProvider
    }
    
    func generateWallet() {
        
        setFirstEnterDateIfNeeded()
        
        guard let provider = walletProvider else { return }
        seedPhrase = provider.manager.generateRandomSeed()
        if let seed = seedPhrase {
            //Payment Code
            
            pcProvider?.generatePaymentCodes(seedPhrase: seed)
            
            guard let walletDigest = accountProvider?.createNewWalletDigest() else {
                return
            }
            
            taskQueueProvider?.addOperation(type: .registrationNew)
            walletProvider?.manager.localCurrencyCode = CurrencyFactory.defaultCurrency.code
        }
    }
    
    fileprivate func setFirstEnterDateIfNeeded() {
        if defaultsProvider?.fitstEnterDate == nil {
            defaultsProvider?.fitstEnterDate = Date()
        }
    }
}

// MARK: - InputTextViewDelegate
extension AddWalletVM: InputTextViewDelegate {
    
    func didChange(value: String) {
        recoveredSeed = value
    }
    
    func didConfirm() {
        setFirstEnterDateIfNeeded()
        
        guard let seed = recoveredSeed else { return }
        do {
            try walletProvider?.manager.recoverWallet(withPhrase: seed)
            delegate?.phraseDidRecoved()
            let walletDigest = accountProvider?.createNewWalletDigest()
            
            icloudProvider?.restoreConfig(walletProvider: walletProvider, defaults: defaultsProvider, currentWalletDigest: walletDigest!)
            icloudProvider?.restoreContacts(contactsProvider: contactsProvider)
            
            pcProvider?.generatePaymentCodes(seedPhrase: seed)
            
            taskQueueProvider?.addOperation(type: .registrationRestore)

        } catch RecoverWalletError.invalidPhraseError {
            showErrorPopupWithString(title: RecoverWalletError.invalidPhraseError.localizedDescription)
        } catch RecoverWalletError.emptyMnemonicError {
            showErrorPopupWithString(title: RecoverWalletError.emptyMnemonicError.localizedDescription)
        } catch RecoverWalletError.phraseNormalizationError {
            showErrorPopupWithString(title: RecoverWalletError.phraseNormalizationError.localizedDescription)
        } catch {
            showErrorPopupWithString(title: RecoverWalletError.unknownError.localizedDescription)
        }
    }
    
    func showErrorPopupWithString(title: String) {
        let popup = PopupView.init(type: .cancel, labelString: title)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
}
