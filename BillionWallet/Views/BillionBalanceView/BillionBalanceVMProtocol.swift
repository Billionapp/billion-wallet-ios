//
//  BillionBalanceVMProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BillionBalanceVMDelegate: class {
    func didStartConnecting()
    func didStartSyncing()
    func syncProgress(_ progress: Float)
    func didEndSyncing()
    func didChangeLockStatus(to isLocked: Bool)
}

protocol BillionBalanceViewFactory {
    func createBalanceView() -> BillionBalanceView
}

protocol BillionBalanceVMProtocol: class {
    var delegate: BillionBalanceVMDelegate? { get set }
    
    // Lock
    var unlockText: String { get }
    var billionText: String { get }
    var biometricsText: Dynamic<String> { get }
    
    // Balance
    var yourBalanceText: String { get }
    var localBalanceText: Dynamic<String> { get }
    var btcBalanceText: Dynamic<String> { get }
    
    // Sync
    var statusText: Dynamic<String> { get }
    var progressText: Dynamic<String> { get }
    var blockDateText: Dynamic<String> { get }
    
    var isTestnet: Bool { get }
    
    func didBindToView()
}
