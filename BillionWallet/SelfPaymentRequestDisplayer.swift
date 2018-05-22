//
//  SelfPaymentRequestDisplayer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct SelfPaymentRequestDisplayer: HistoryDisplayable {

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
    let requestID: String
    let requestState: SelfPaymentRequestState
    
    init(selfPaymentRequest: SelfPaymentRequest, contactsProvider: ContactsProvider, fiatConverter: FiatConverter) {
        
        self.identity = "\(type(of: self)):\(selfPaymentRequest.identifier)"
        self.requestID =  "\(selfPaymentRequest.identifier)"
        self.requestState = selfPaymentRequest.state
        self.title = fiatConverter.fiatStringForBtcValue(UInt64(selfPaymentRequest.amount))
        self.subtitle =  Satoshi.amount(UInt64(selfPaymentRequest.amount))
        self.sortPriority = .high
        if let contactId = selfPaymentRequest.contactID {
            self.connection = contactsProvider.getFriendContact(paymentCode: contactId)
        } else {
            self.connection = nil
        }
        switch selfPaymentRequest.state {
        case .inProgress:
            self.header = Strings.PaymentRequest.requestInProgress
        case .rejected:
            self.header = Strings.PaymentRequest.requestRejected
        }
        self.rawAmount = UInt64(selfPaymentRequest.amount)
        let interval = TimeInterval(selfPaymentRequest.identifier) ?? Date().timeIntervalSince1970
        self.time = Date(timeIntervalSince1970: interval)
        self.interaction = .timestamp(timestamp: time.humanReadable)
        self.bubbleImage = #imageLiteral(resourceName: "BubbleGray").withHorizontallyFlippedOrientation()
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

