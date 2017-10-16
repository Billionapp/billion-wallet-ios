//
//  Transaction.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct Transaction {
    
    enum Status {
        case pending
        case invalid
        case unverified
        case confirmations(count: UInt32)
        case succed
        
        var title: String? {
            switch self {
            case .pending:
                return NSLocalizedString("Pending", comment: "")
            case .invalid:
                return NSLocalizedString("Invalid", comment: "")
            case .unverified:
                return NSLocalizedString("Unverified", comment: "")
            case .confirmations(let count):
                return NSLocalizedString("\(count) confirmation", comment: "")
            case .succed:
                return nil
            }
        }
    }
    
    let brTransaction: BRTransaction
    
    var contact: ContactProtocol?
    var isNotificationTx: Bool

    var received: UInt64 {
        return manager.wallet?.amountReceived(from: brTransaction) ?? 0
    }
    
    var sent: UInt64 {
        return manager.wallet?.amountSent(by: brTransaction) ?? 0
    }
    
    var amount: Int64 {
        if isReceived {
            return Int64(received)
        } else {
            return Int64(received) - Int64(sent)
        }
    }
    
    var fee: UInt64 {
        return manager.wallet?.fee(for: brTransaction) ?? 0
    }
    
    var timestamp: Date? {
        return Date(timeIntervalSince1970: brTransaction.timestamp + NSTimeIntervalSince1970)
    }
    
    var blockHeight: UInt32? {
        return brTransaction.blockHeight
    }
    
    var txHash: UInt256S {
        return UInt256S(brTransaction.txHash)
    }
    
    var status: Status {
        
        guard let wallet = manager.wallet else {
            return .invalid
        }
        
        if confirmations == 0 {
            
            if !wallet.transactionIsValid(brTransaction) {
                return .invalid
                
            } else if wallet.transactionIsPending(brTransaction) {
                return .pending
            
            } else if !wallet.transactionIsVerified(brTransaction) {
                return .unverified
            }
            
        } else if confirmations < 6 {
            return .confirmations(count: confirmations)
        }
        
        return .succed
    }
    
    var localCurrencyAmount: String {
        let iso = manager.localCurrencyCode ?? "USD"
        let rateArray = rates?.filter{$0.currencyCode == iso}
        var btcRate:UInt64 = 0
        if let rate = rateArray?.first {
            btcRate = UInt64(rate.btc)
        }else{
            btcRate = UInt64(manager.localCurrencyPrice)
        }
        
        if isReceived {
            return stringCurrency(from: received*btcRate/UInt64(SATOSHIS), localeIso: iso)
        } else {
            let sentAmount = sent-received-fee
            return stringCurrency(from: sentAmount*btcRate/UInt64(SATOSHIS), localeIso: iso)
        }
    }
    
    var bitsAmount: String {
        if isReceived {
            return manager.string(forAmount: Int64(received))
        } else {
            return manager.string(forAmount: Int64(received) - Int64(sent))
        }
    }
    
    var confirmations: UInt32 {
        guard let blockHeight = blockHeight else {
            return 0
        }
        return (blockHeight > peer.lastBlockHeight) ? 0 : (peer.lastBlockHeight - blockHeight) + 1
    }
    
    var isReceived: Bool {
        return !(sent > 0)
    }
    
    var rates: [Rate]?
    
    fileprivate var manager: BRWalletManager {
        return BRWalletManager.sharedInstance()!
    }
    
    fileprivate var peer: BRPeerManager {
        return BRPeerManager.sharedInstance()!
    }
    /*
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Transaction(brTransaction: brTransaction, contact: contact)
        return copy
    }*/
}
