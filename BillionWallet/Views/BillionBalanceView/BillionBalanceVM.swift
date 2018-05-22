//
//  BillionBalanceVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BillionBalanceVM: NSObject, BillionBalanceVMProtocol {
    typealias LocalizedStrings = Strings.Balance
    
    private let defaults: Defaults
    private let peerManager: BPeerManager
    private let walletProvider: WalletProvider
    private let lockProvider: LockProvider
    private let fiatConverter: FiatConverter
    private let localAuthProvider: TouchIDManager
    private let dateFormatter: DateFormatter
    
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
    
    var isTestnet: Bool {
        #if BITCOIN_TESTNET
        return true
        #else
        return false
        #endif
    }
    
    init(defaults: Defaults,
         peerManager: BPeerManager,
         wallet: WalletProvider,
         lockProvider: LockProvider,
         fiatConverter: FiatConverter,
         localAuthProvider: TouchIDManager) {
        
        self.defaults = defaults
        self.peerManager = peerManager
        self.walletProvider = wallet
        self.lockProvider = lockProvider
        self.fiatConverter = fiatConverter
        self.localAuthProvider = localAuthProvider
        
        self.dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(startSyncing),
                                               name: .syncStarted,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance),
                                               name: .walletBalanceChangedNotificationName,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateLockStatus),
                                               name: .didUpdateLockStatus,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance),
                                               name: .walletSwitchCurrencyNotificationName,
                                               object: nil)
    }
    
    @objc
    private func startSyncing() {
        delegate?.didStartSyncing()
        self.perform(#selector(progressInc), with: nil, afterDelay: 0.5)
    }
    
    @objc
    private func progressInc() {
        if (try? walletProvider.getWallet()) == nil { return }
        let isConnected = walletProvider.isConnectedToDownloadPeer()
        if !isConnected {
            statusText &= LocalizedStrings.connecting
            delegate?.didStartConnecting()
            self.perform(#selector(progressInc), with: nil, afterDelay: 0.5)
            return
        }

        let syncProgress = walletProvider.syncProgress
        let isSynced = syncProgress == 1.0
        
        if isSynced {
            statusText &= LocalizedStrings.synced
            delegate?.didEndSyncing()
            return
        }
        
        var syncingText = ""
        let currentBlock = walletProvider.lastBlock()
        if defaults.useBlockSyncIndication {
            let estimatedBlock = walletProvider.estimatedBlockHeight
            syncingText = String(format: "%ld / %ld", currentBlock.height, estimatedBlock)
        } else {
            syncingText = String(format: "%.0lf%%", syncProgress * 100)
        }
        
        let blockTs = currentBlock.timestamp
        let date = Date(timeIntervalSince1970: TimeInterval(blockTs))
        let dateText = dateFormatter.string(from: date)
        
        statusText &= LocalizedStrings.syncing
        progressText &= syncingText
        blockDateText &= dateText
        delegate?.syncProgress(Float(syncProgress))
        self.perform(#selector(progressInc), with: nil, afterDelay: 0.5)
    }
    
    @objc
    private func updateBalance() {
        guard let wallet = try? walletProvider.getWallet() else { return }
        
        let balance = wallet.balance
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

        if !walletProvider.isConnectedToDownloadPeer() {
            delegate?.didStartConnecting()
        } else if peerManager.syncProgress < 1.0 {
            delegate?.didStartSyncing()
        }
    }
}
