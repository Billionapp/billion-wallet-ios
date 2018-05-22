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
    
    typealias LocalizedStrings = Strings.Settings.General
    
    private let network: Network
    private weak var defaultsProvider: Defaults!
    private weak var iCloudProvider: ICloud!
    private weak var accountProvider: AccountManager!
    private weak var taskQueue: TaskQueueProvider!
    private weak var failureTxProvider: FailureTxProtocol!
    private weak var contactsProvider: ContactsProvider!
    private var messageFetchProvider: MessageFetchProviderProtocol
    private weak var userPaymentRequestProvider: UserPaymentRequestProtocol!
    private weak var selfPaymentRequestProvider: SelfPaymentRequestProtocol!
    private let keychain: Keychain
    private let lockProvider: LockProvider
    private let walletProvider: BPeerManager
    private let rateQ: RateQueueProtocol
    
    private let ratesProvider: RateProviderProtocol
    private let feeProvider: FeeProvider
    
    weak var delegate: SettingsVMDelegate?
    
    init(network: Network,
         defaultsProvider: Defaults,
         keychain: Keychain,
         lockProvider: LockProvider,
         iCloudProvider: ICloud,
         accountProvider: AccountManager,
         walletProvider: WalletProvider,
         ratesProvider: RateProviderProtocol,
         feeProvider: FeeProvider,
         tastQueue: TaskQueueProvider,
         failureTxProvider: FailureTxProtocol,
         contactsProvider: ContactsProvider,
         messageFetchProvider: MessageFetchProviderProtocol,
         userPaymentRequestProvider: UserPaymentRequestProtocol,
         selfPaymentRequestProvider: SelfPaymentRequestProtocol,
         rateQ: RateQueueProtocol) {
        
        self.network = network
        self.defaultsProvider = defaultsProvider
        self.iCloudProvider = iCloudProvider
        self.accountProvider = accountProvider
        self.walletProvider = walletProvider
        self.failureTxProvider = failureTxProvider
        self.contactsProvider = contactsProvider
        self.messageFetchProvider = messageFetchProvider
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
        self.keychain = keychain
        self.lockProvider = lockProvider
        self.ratesProvider = ratesProvider
        self.feeProvider = feeProvider
        self.taskQueue = tastQueue
        self.rateQ = rateQ
    }
    
    var currencies: [Currency] {
        return defaultsProvider.currencies
    }
    
    var mnemonic: String? {
        return accountProvider.getMnemonic()
    }
    
    var securityButtonText: String {
        if Layout.model == .ten {
            return LocalizedStrings.securityX
        } else {
            return LocalizedStrings.security
        }
    }
    
    func saveConfig() {
        guard let walletDigest = accountProvider.getOrCreateWalletDigest() else {
            Logger.error("Could not save to iCloud")
            return
        }
        
        let iCloudConfig = ICloudConfig(walletDigest: walletDigest,
                                        userName: "User",
                                        currencies: currencies,
                                        feeSize: FeeSize.custom,
                                        version: Bundle.appVersion)
        let iCloud = iCloudProvider!
        DispatchQueue.global().async {
            do {
                try iCloud.backup(object: iCloudConfig)
            } catch let error {
                // ICloud.ICloudError.couldntSave
                Logger.error(error.localizedDescription)
            }
        }
        
    }
    
    func setIsLocked(_ value: Bool) {
        if value {
            lockProvider.lock()
        } else {
            lockProvider.unlock()
        }
    }
    
    func clearAll(clearCloud: Bool) {
        network.stopAllOperations()
        rateQ.cancelAll()
        if clearCloud {
            iCloudProvider.wipe()
        }
        
        defaultsProvider.clear()
        keychain.deleteAll()
        feeProvider.stopTimer()
        taskQueue.stop()
        taskQueue.clear()
        messageFetchProvider.stopFetching()
        
        contactsProvider.deleteAllContacts()
        failureTxProvider.deleteAllFailureTxs {}
        userPaymentRequestProvider.deleteAllUserPaymentRequest {}
        selfPaymentRequestProvider.deleteAllSelfPaymentRequest {}
        
        accountProvider.clearAccountKeychain()
        accountProvider.deleteWallet()
    }
    
    func rescanBlockchain() {
        walletProvider.rescan()
    }
}

// MARK: - PasscodeOutputDelegate

extension SettingsVM: PasscodeOutputDelegate {
    
    func didUpdatePasscode(_ passcode: String) {
        
    }
    
    func didCompleteVerification() {
        delegate?.didComleteVerification()
    }
    
}
