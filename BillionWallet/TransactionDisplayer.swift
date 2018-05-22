//
//  TransactionDisplayer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 13/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct TransactionDisplayer: HistoryDisplayable {
    
    typealias LocalizedStrings = Strings.General
    
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
    let isOutgoingNotificationTx: Bool
    let localCurrencyAmount: String
    var localCurrencyAmountNow: String?
    let isReceived: Bool
    let balanceAfterTransaction: UInt64
    let statusText: String
    var satoshiAmount: String?
    let confirmations: UInt32
    let confirmationsText: String
    let localFeeAmount: String
    let avatarImage: UIImage?
    var totalSatoshiAmount: String?
    let txHash: UInt256S
    let txHashString: String
    var myAddress: String?
    var partnerAddress: String?
    
    init(transaction: Transaction,
         walletProvider: WalletProvider,
         defaults: Defaults,
         fiatConverter: FiatConverter,
         historicalFiatConverter: FiatConverter) {
        
        self.identity = "\(type(of: self)):\(transaction.txHash.data.hex)"
        self.connection = transaction.contact
        self.isReceived = transaction.isReceived
        
        switch transaction.status {
            case .pending:
                self.statusText = LocalizedStrings.txPending
            case .invalid:
                self.statusText = LocalizedStrings.txInvalid
            case .unverified:
                self.statusText = LocalizedStrings.txUnverified
            case .confirmations(let count):
                if count == 1 {
                    self.statusText =  String(format: LocalizedStrings.confirmationsFormatSingle, count)
                } else {
                    self.statusText = String(format: LocalizedStrings.confirmationsFormatPlural, count)
                }
            case .matured:
                self.statusText = transaction.isReceived ? LocalizedStrings.txTypeIncoming : LocalizedStrings.txTypeOutgoing
        }
        
        if let pcString = transaction.contact?.uniqueValue,
            let paymentCode = try? PaymentCode(with: pcString),
            let notificationAddress = paymentCode.notificationAddress {
            self.isOutgoingNotificationTx = transaction.outputAddresses.contains(notificationAddress)
        } else {
            self.isOutgoingNotificationTx = false
        }
        
        if isOutgoingNotificationTx {
            self.title = Strings.NotificationDetails.networkFee
            self.subtitle = Strings.NotificationDetails.privateConnection
            self.sortPriority = .high
            self.header = Strings.NotificationDetails.blockchain
            self.bubbleImage = #imageLiteral(resourceName: "BubbleGray").withHorizontallyFlippedOrientation()
            let amountSent = abs(Int64(transaction.sent) - Int64(transaction.received))
            self.totalSatoshiAmount = Satoshi.amount(UInt64(amountSent))
            self.localCurrencyAmount = historicalFiatConverter.fiatStringForBtcValue(UInt64(amountSent))
        } else {
            if transaction.isReceived {
                self.localCurrencyAmount = historicalFiatConverter.fiatStringForBtcValue(transaction.received)
                self.localCurrencyAmountNow = fiatConverter.fiatStringForBtcValue(transaction.received)
                self.title = "+ " + self.localCurrencyAmount
                self.satoshiAmount = Satoshi.amount(transaction.received)
                self.subtitle = self.satoshiAmount!
                self.bubbleImage = #imageLiteral(resourceName: "BubbleGreenLeft")
            } else {
                let sentAmount = abs(Int64(transaction.sent) - Int64(transaction.received) - Int64(transaction.fee))
                self.localCurrencyAmount = historicalFiatConverter.fiatStringForBtcValue(UInt64(sentAmount))
                self.localCurrencyAmountNow = fiatConverter.fiatStringForBtcValue(UInt64(sentAmount))
                self.title = "- " + self.localCurrencyAmount
                self.satoshiAmount = Satoshi.amount(UInt64(sentAmount))
                self.subtitle = self.satoshiAmount!
                self.bubbleImage = #imageLiteral(resourceName: "BubbleRedRight")
            }
            self.sortPriority = .normal
            if let givenName = transaction.contact?.givenName {
                self.header = givenName
            } else {
                self.header = self.statusText
            }
        }
        
        self.balanceAfterTransaction = transaction.balanceAfterTransaction
        self.localFeeAmount = fiatConverter.fiatStringForBtcValue(transaction.fee)
        self.time = transaction.dateTimestamp
        if time.timeIntervalSinceReferenceDate != 0 {
            self.interaction = .timestamp(timestamp: time.humanReadable)
        } else {
            self.interaction = .timestamp(timestamp: "")
        }
        self.txHash = transaction.txHash
        self.txHashString = Data(transaction.txHash.data.reversed()).hex
        self.confirmations = transaction.confirmations
        self.confirmationsText = confirmations > 6 ? "6 +" : "\(confirmations)"
        self.avatarImage = self.connection?.avatarImage
        self.rawAmount = transaction.amount
        self.stateHash = String(format: "%@|%@|%ld|%@|%ld|%@|%@|%@|%@",
                                identity,
                                localCurrencyAmount,
                                min(transaction.confirmations, 7),
                                connection?.displayName ?? "nil",
                                connection?.avatarData?.hashValue ?? 0,
                                connection?.uniqueValue ?? "nil",
                                header,
                                title,
                                subtitle)
        
        if let wallet = try? walletProvider.getWallet() {
            let outputsAddresses = transaction.outputAddresses
            self.myAddress = outputsAddresses.first { wallet.containsAddress($0) == true }
            if transaction.isReceived {
                let outputIndex = transaction.outputAmounts.index(of: transaction.amount) ?? 0
                self.partnerAddress = transaction.outputAddresses[outputIndex]
            } else {
                let outputsAddresses = transaction.outputAddresses
                self.partnerAddress = wallet.partnerAddress(from: outputsAddresses) ?? "NO_ADDRESS"
            }
        }
    }
    
    func showDetails(visitor: HistoryDisplayableVisitor, cellY: CGFloat, backImage: UIImage) {
        visitor.showDetails(for: self, cellY: cellY, backImage: backImage)
    }
    
}
