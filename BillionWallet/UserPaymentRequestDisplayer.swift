//
//  UserPaymentRequestDisplayer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct UserPaymentRequestDisplayer: HistoryDisplayable {
    
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
    let userPaymentRequest: UserPaymentRequest
    let amount: UInt64
    
    init(userPaymentRequest: UserPaymentRequest, fiatConverter: FiatConverter, contactsProvider: ContactsProvider) {
        self.identity = "\(type(of: self)):\(userPaymentRequest.identifier)"
        self.userPaymentRequest = userPaymentRequest
        self.title = fiatConverter.fiatStringForBtcValue(UInt64(userPaymentRequest.amount))
        self.subtitle =  Satoshi.amount(UInt64(userPaymentRequest.amount))
        self.amount = UInt64(userPaymentRequest.amount)
        self.sortPriority = .high
        if let contactId = userPaymentRequest.contactID {
            self.connection = contactsProvider.getFriendContact(paymentCode: contactId)
        } else {
            self.connection = nil
        }
        switch userPaymentRequest.state {
        case .declined:
            self.header = Strings.PaymentRequest.requestDeclined
        default:
            self.header = Strings.PaymentRequest.receiverRequest
        }
        self.rawAmount = UInt64(userPaymentRequest.amount)
        let interval = TimeInterval(userPaymentRequest.identifier) ?? Date().timeIntervalSince1970
        self.time = Date(timeIntervalSince1970: interval)
        switch userPaymentRequest.state {
        case .declined:
            self.interaction = .timestamp(timestamp: time.humanReadable)
        default:
            self.interaction = .interaction(icon: #imageLiteral(resourceName: "InteractionMore"))
        }
        self.bubbleImage = #imageLiteral(resourceName: "BubbleGray")
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
