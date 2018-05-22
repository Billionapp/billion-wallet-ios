//
//  SelfPaymentRequestDetailsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol SelfPRVMProtocol: class {
    var title: String { get }
    var subtitle: String { get }
    
    var timestamp: String { get }
    var avatarImage: UIImage { get }
    var isRejected: Bool { get }
    var delegate: SelfPRDetailsVMDelegate? { get set }
    var cellY: CGFloat { get set }
    
    func cancelRequest()
    func deleteRequest()
}

protocol SelfPRDetailsVMDelegate: class {
    func didCancelRequest()
}

class SelfPRDetailsVM: SelfPRVMProtocol {

    private var displayer: SelfPaymentRequestDisplayer
    private weak var walletProvider: WalletProvider!
    private weak var selfPaymentRequestProvider: SelfPaymentRequestProtocol!
    private var messageSendProvider: RequestSendProviderProtocol!
    private let fiatConverter: FiatConverter
    
    var delegate: SelfPRDetailsVMDelegate?
    var cellY: CGFloat
    
    init(displayer: SelfPaymentRequestDisplayer,
         walletProvider: WalletProvider,
         selfPaymentRequestProvider: SelfPaymentRequestProtocol,
         fiatConverter: FiatConverter,
         cellY: CGFloat,
         messageSendProvider: RequestSendProviderProtocol) {
        
        self.displayer = displayer
        self.selfPaymentRequestProvider = selfPaymentRequestProvider
        self.messageSendProvider = messageSendProvider
        self.walletProvider = walletProvider
        self.fiatConverter = fiatConverter
        self.cellY = cellY
    }
    
    var title: String {
        return displayer.title
    }
    
    var subtitle: String {
        return displayer.subtitle
    }

    var timestamp: String {
        if let timeInterval = TimeInterval(displayer.requestID) {
            let date = Date(timeIntervalSince1970: timeInterval)
            return date.humanReadable
        } else {
            return "NO_DATE"
        }
    }
    
    var isRejected: Bool {
        return displayer.requestState == .rejected
    }
    
    var avatarImage: UIImage {
        guard let contact = displayer.connection as? PaymentCodeContactProtocol else {
            return #imageLiteral(resourceName: "QRIcon")
        }
    
        return contact.avatarImage
    }
    
    func deleteRequest() {
        selfPaymentRequestProvider.deleteSelfPaymentRequest(identifier: displayer.requestID, completion: {
            Logger.info("Payment request deleted")
        }) { error in
            Logger.error(error.localizedDescription)
        }
    }
    
    func cancelRequest() {
        if let contact = displayer.connection {
            messageSendProvider.cancelRequest(identifier: displayer.requestID, contact: contact, completion: { result in
                switch result {
                case .success:
                    self.delegate?.didCancelRequest()
                case .failure(let error):
                    Logger.error("Request cenceling failed with: \(error.localizedDescription)")
                }
            })
        }
    }
}
