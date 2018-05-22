//
//  PaymentRequestDetailsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol PaymentRequestDetailsVMDelegate: class {
    func didOverflow()
    func didEnterCorrectAmount()
}

class PaymentRequestDetailsVM {

    var displayer: UserPaymentRequestDisplayer
    weak var delegate: PaymentRequestDetailsVMDelegate?
    weak var walletProvider: WalletProvider!
    weak var userPaymentRequestProvider: UserPaymentRequestProtocol!
    private let fiatConverter: FiatConverter
    private let maxSendAmountBuilder: MaxSendAmountBuilder
    private var maxSendAmount: MaxSendAmount
    var messageSendProvider: RequestSendProviderProtocol!
    var cellY: CGFloat

    init(maxSendAmountBuilder: MaxSendAmountBuilder,
         displayer: UserPaymentRequestDisplayer,
         walletProvider: WalletProvider,
         userPaymentRequestProvider: UserPaymentRequestProtocol,
         fiatConverter: FiatConverter,
         messageSendProvider: RequestSendProviderProtocol,
         cellY: CGFloat) {
        
        self.maxSendAmountBuilder = maxSendAmountBuilder
        self.maxSendAmount = maxSendAmountBuilder.zeroMaxSendAmount()
        self.displayer = displayer
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.walletProvider = walletProvider
        self.fiatConverter = fiatConverter
        self.messageSendProvider = messageSendProvider
        self.cellY = cellY
    }
    
    func calculateMaxSendAmount() {
        do {
            maxSendAmount = try maxSendAmountBuilder.buildMaxSendAmount()
            verifyAmount()
        } catch let error {
            Logger.error("Cannot calculate max send amount: \(error.localizedDescription)")
        }
    }
    
    private func verifyAmount() {
        if displayer.userPaymentRequest.amount > maxSendAmount.safeMaxAmount {
            delegate?.didOverflow()
        } else {
            delegate?.didEnterCorrectAmount()
        }
    }
    
    var avatarImage: UIImage {
        guard let contact = displayer.connection as? PaymentCodeContactProtocol else {
            return #imageLiteral(resourceName: "QRIcon")
        }
        
        return contact.avatarImage
    }
    
    func getContact() -> PaymentCodeContactProtocol? {
        return displayer.connection as? PaymentCodeContactProtocol
    }
    
    func deleteRequest() {
        userPaymentRequestProvider.deleteUserPaymentRequest(identifier: displayer.userPaymentRequest.identifier, completion: {
            Logger.info("Payment request deleted")
        }) { error in
            Logger.error(error.localizedDescription)
        }
    }
    
    func declineRequest() {
        if let contact = displayer.connection {
            messageSendProvider.declineRequest(identifier: displayer.userPaymentRequest.identifier, contact: contact, completion: { result in
                switch result {
                case .success:
                    Logger.info("Payment request declined")
                case .failure(let error):
                    Logger.error(error.localizedDescription)
                }
            })
        } else {
            userPaymentRequestProvider.changeToState(identifier: displayer.userPaymentRequest.identifier, state: .declined, completion: {
                Logger.info("Payment request declined")
            }) { error in
                Logger.error(error.localizedDescription)
            }
        }
    }
}
