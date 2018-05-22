//
//  FailureTxDisplayer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct FailureTxDisplayer: HistoryDisplayable {
    
    let identity: String
    let title: String
    let subtitle: String
    let sortPriority: SortPriority
    let connection: ContactProtocol?
    let header: String
    let rawAmount: UInt64
    let time: Date
    let interaction: InteractionType
    let bubbleImage: UIImage
    let stateHash: String
    let address: String
    let failureTx: FailureTx
    
    init(failureTx: FailureTx, fiatConverter: FiatConverter, contactsProvider: ContactsProvider) {
        
        self.identity = "\(type(of: self)):\(failureTx.identifier)"
        self.failureTx = failureTx
        self.address = failureTx.address
        self.title = fiatConverter.fiatStringForBtcValue(UInt64(failureTx.amount))
        self.subtitle =  Satoshi.amount(failureTx.amount)
        self.sortPriority = .normal
        self.connection = contactsProvider.paymentCodeProtocolContacts.filter { $0.paymentCode == failureTx.contactID }.first
        self.header = Strings.TxFailure.header
        self.rawAmount = failureTx.amount
        let interval = TimeInterval(failureTx.identifier) ?? Date().timeIntervalSince1970
        self.time = Date(timeIntervalSince1970: interval)
        self.interaction = .interaction(icon: #imageLiteral(resourceName: "errorIcon"))
        self.bubbleImage = #imageLiteral(resourceName: "BubbleRedRight").image(alpha: 0.5)!
        self.stateHash = String(format: "%@|%@|%ld|%@|%@|%@|%@",
                                identity,
                                connection?.displayName ?? "nil",
                                connection?.avatarData?.hashValue ?? 0,
                                connection?.uniqueValue ?? "nil",
                                header,
                                title,
                                subtitle)
    }
    
    func showDetails(visitor: HistoryDisplayableVisitor, cellY: CGFloat, backImage: UIImage) {
        visitor.showDetails(for: self, cellY: cellY, backImage: backImage)
    }
}
