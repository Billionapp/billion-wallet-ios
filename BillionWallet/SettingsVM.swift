//
//  SettingsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol SettingsVMDelegate: class {
    func didComleteVerification()
}

class SettingsVM {
    
    let defaultsProvider: Defaults
    let iCloudProvider: ICloud
    let accountProvider: AccountManager
    var keychain: Keychain
    
    var currencies: [Currency] {
        return defaultsProvider.currencies
    }
    
    let ratesProvider: RatesProvider
    let feeProvider: FeeProvider
    
    var commission: FeeSize {
        return defaultsProvider.commission
    }

    var mnemonic: String? {
        return accountProvider.getMnemonic()
    }
    
    weak var delegate: SettingsVMDelegate?

    init(defaultsProvider: Defaults, keychain: Keychain, iCloudProvider: ICloud, accountProvider: AccountManager, ratesProvider: RatesProvider, feeProvider: FeeProvider) {
        self.defaultsProvider = defaultsProvider
        self.iCloudProvider = iCloudProvider
        self.accountProvider = accountProvider
        self.keychain = keychain
        self.ratesProvider = ratesProvider
        self.feeProvider = feeProvider
    }
    
    func saveConfig() {
        do {
            guard let walletDigest = accountProvider.currentWalletDigest else {
                throw ICloud.ICloudError.couldntSave
            }
            
            let iCloudConfig = ICloudConfig(walletDigest: walletDigest, userName: "User", currencies: currencies, feeSize: commission, version: Bundle.appVersion)
            try iCloudProvider.backup(object: iCloudConfig)
            
        } catch {
            // ICloud.ICloudError.couldntSave
            Logger.error(error.localizedDescription)
        }
    }
    
    func clearAll() {
        accountProvider.deleteWallet()
        accountProvider.clearAccountKeychain()
        defaultsProvider.clear()
        keychain.pin = nil
        keychain.isLocked = false
        ratesProvider.stopTimer()
        feeProvider.stopTimer()
        
        // TODO: refactor
        let contactsProvider = ContactsProvider()
        contactsProvider.deleteAllContacts()
    }
    
}

// MARK: - PasscodeOutputDelegate

extension SettingsVM: PasscodeOutputDelegate {
    
    func didUpdatePascode(_ passcode: String) {
        
    }
    
    func didCompleteVerification() {
        delegate?.didComleteVerification()
    }
    
}
