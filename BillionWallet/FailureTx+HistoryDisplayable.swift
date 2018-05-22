//
//  FailureTx+HistoryDisplayable.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension FailureTx: HistoryDisplayable {
    var rawAmount: UInt64? {
        return amount
    }
    
    var connection: ContactProtocol? {
        // FIXME: remove static calls
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let icloud = appDelegate.app.iCloud
        let contactProvider = ContactsProvider(iCloudProvider: icloud)
        let contact = contactProvider.paymentCodeProtocolContacts.filter { $0.paymentCode == contactID }.first
        return contact
    }
    
    var header: String? {
        return Strings.TxFailure.header
    }
    
    var title: String? {
        //FIXME: DI
        let manager = BRWalletManager.sharedInstance()!
        let iso = manager.localCurrencyCode ?? "USD"
        let btcRate = manager.localCurrencyPrice
        return "- " + stringCurrency(from: abs(round(Double(amount)*btcRate/Double(1e8))), localeIso: iso)
    }
    
    var subtitle: String? {
        return Satoshi.amount(amount)
    }
    
    var interaction: InteractionType {
        return .interaction(icon: #imageLiteral(resourceName: "errorIcon"))
    }
    
    var bubbleImage: UIImage? {
        return #imageLiteral(resourceName: "BubbleRedRight").image(alpha: 0.5)
    }
    
    var time: Date {
        let interval = TimeInterval(identifier.rawValue) ?? Date().timeIntervalSince1970
        return Date(timeIntervalSince1970: interval)
    }
    
    func showDetails(visitor: HistoryDisplayableVisitor, cellY: CGFloat, backImage: UIImage) {
        visitor.showDetails(for: self, cellY: cellY, backImage: backImage)
    }

}
