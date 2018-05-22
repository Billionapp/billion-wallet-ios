//
//  TxDetailsBalanceVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TxDetailsBalanceVM: NSObject, BillionBalanceVMProtocol {
    typealias LocalizedStrings = Strings.Balance
    
    private let defaults: Defaults
    private let peerManager: BPeerManager
    private let walletManager: BWalletManager
    private let lockProvider: LockProvider
    private let fiatConverter: FiatConverter
    private let localAuthProvider: TouchIDManager
    
    var balance: UInt64 {
        didSet {
            self.updateBalance()
        }
    }
    
    weak var delegate: BillionBalanceVMDelegate?
    
    var unlockText: String
    var billionText: String
    var biometricsText: Dynamic<String>
    
    var yourBalanceText: String
    var localBalanceText: Dynamic<String>
    var btcBalanceText: Dynamic<String>
    
    var statusText: Dynamic<String>
    var progressText: Dynamic<String>
    var blockDateText: Dynamic<String>
    
    init(defaults: Defaults,
         peerManager: BPeerManager,
         walletManager: BWalletManager,
         lockProvider: LockProvider,
         fiatConverter: FiatConverter,
         localAuthProvider: TouchIDManager) {
        
        self.defaults = defaults
        self.peerManager = peerManager
        self.walletManager = walletManager
        self.lockProvider = lockProvider
        self.fiatConverter = fiatConverter
        self.localAuthProvider = localAuthProvider
        self.balance = 0
        
        self.unlockText = LocalizedStrings.unlockText
        self.billionText = LocalizedStrings.billionText
        self.biometricsText = Dynamic("")
        
        self.yourBalanceText = LocalizedStrings.balanceAfter
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
    
    var isTestnet: Bool {
        #if BITCOIN_TESTNET
            return true
        #else
            return false
        #endif
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
        NotificationCenter.default.addObserver(self, selector: #selector(startSyncing),
                                               name: .syncStarted,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance),
                                               name: .walletBalanceChangedNotificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLockStatus),
                                               name: .didUpdateLockStatus,
                                               object: nil)
    }
    
    @objc
    private func startSyncing() {
        self.perform(#selector(progressInc), with: nil, afterDelay: 0.5)
    }
    
    @objc
    private func progressInc() {
        if walletManager.noWallet { return }
    
        let isConnected = peerManager.isConnectedToDownloadPeer()
        if !isConnected {
            self.perform(#selector(progressInc), with: nil, afterDelay: 0.5)
            return
        }
    
        let syncProgress = peerManager.syncProgress
        let isSynced = syncProgress == 1.0
        
        if isSynced {
            delegate?.didEndSyncing()
            return
        }
        
        delegate?.syncProgress(Float(syncProgress))
        self.perform(#selector(progressInc), with: nil, afterDelay: 0.5)
    }
    
    @objc
    private func updateBalance() {
        fiatConverter.changeCurrency(newCurrency: defaults.currencies.first!)
        let localBalance = fiatConverter.fiatStringForBtcValue(balance)
        let btc = Satoshi.amount(balance)
        
        self.localBalanceText &= localBalance
        self.btcBalanceText &= btc
    }
    
    @objc
    func didUpdateLockStatus() {
        self.biometricsText &= getBiometricsText()
        delegate?.didChangeLockStatus(to: lockProvider.isLocked)
    }
    
    func didBindToView() {
        self.updateBalance()
        delegate?.didChangeLockStatus(to: lockProvider.isLocked)
    
        if peerManager.syncProgress < 1.0 {
            self.startSyncing()
        }
    }
}

