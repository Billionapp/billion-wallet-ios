//
//  SendInputBalanceVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SendInputBalanceVM: NSObject, BillionBalanceVMProtocol {
    typealias LocalizedStrings = Strings.Balance
    
    private let defaults: Defaults
    private let walletProvider: WalletProvider
    private let lockProvider: LockProvider
    private let fiatConverter: FiatConverter
    private let localAuthProvider: TouchIDManager
    
    var delegate: BillionBalanceVMDelegate?
    
    var unlockText: String
    var billionText: String
    var biometricsText: Dynamic<String>
    
    var yourBalanceText: String
    var localBalanceText: Dynamic<String>
    var btcBalanceText: Dynamic<String>
    
    var statusText: Dynamic<String>
    var progressText: Dynamic<String>
    var blockDateText: Dynamic<String>
    
    var isTestnet: Bool {
        #if BITCOIN_TESTNET
            return true
        #else
            return false
        #endif
    }
    
    init(defaults: Defaults,
         walletProvider: WalletProvider,
         lockProvider: LockProvider,
         fiatConverter: FiatConverter,
         localAuthProvider: TouchIDManager) {
        
        self.defaults = defaults
        self.walletProvider = walletProvider
        self.lockProvider = lockProvider
        self.fiatConverter = fiatConverter
        self.localAuthProvider = localAuthProvider
        
        self.unlockText = LocalizedStrings.unlockText
        self.billionText = LocalizedStrings.billionText
        self.biometricsText = Dynamic("")
        
        self.yourBalanceText = LocalizedStrings.yourBalanceText
        self.localBalanceText = Dynamic("")
        self.btcBalanceText = Dynamic("")
        
        self.statusText = Dynamic("")
        self.progressText = Dynamic("")
        self.blockDateText = Dynamic("")
        
        super.init()
        
        setDynamicInitialValues()
        subscribeToNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setDynamicInitialValues() {
        biometricsText &= getBiometricsText()
        updateBalance()
    }
    
    private func getBiometricsText() -> String {
        if localAuthProvider.isTouchIdOn {
            if #available(iOS 11.0, *) {
                if localAuthProvider.faceIdIsAvaliable() {
                    return LocalizedStrings.unlockWithFaceId
                }
            }
            return LocalizedStrings.unlockWithTouchId
        } else {
            return LocalizedStrings.unlockWithPin
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance),
                                               name: .walletBalanceChangedNotificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLockStatus),
                                               name: .didUpdateLockStatus,
                                               object: nil)
    }
    
    @objc
    private func updateBalance() {
        guard let wallet = try? walletProvider.getWallet() else { return }
        
        let balance = wallet.balance
        fiatConverter.changeCurrency(newCurrency: defaults.currencies.first!)
        let localBalance = fiatConverter.fiatStringForBtcValue(balance)
        let btc = Satoshi.amount(balance)
        
        self.localBalanceText &= localBalance
        self.btcBalanceText &= btc
    }
    
    @objc
    private func didUpdateLockStatus() {
        self.biometricsText &= getBiometricsText()
        delegate?.didChangeLockStatus(to: lockProvider.isLocked)
    }
    
    func didBindToView() {
        self.updateBalance()
        delegate?.didChangeLockStatus(to: lockProvider.isLocked)
        delegate?.syncProgress(0.0)
    }
}
