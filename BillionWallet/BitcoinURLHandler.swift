//
//  BitcoinURLHandler.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol BitcoinUrlHandlerProtocol {
    func handle(urlData: BitcoinUrlData)
}

class BitcoinUrlHandler: BitcoinUrlHandlerProtocol {
    private let userPaymentRequestProvider: UserPaymentRequestProtocol
    private let router: MainRouter
    
    init(userPaymentRequestProvider: UserPaymentRequestProtocol, router: MainRouter) {
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.router = router
    }
    
    private lazy var noOP: () -> Void = { }
    
    private lazy var failureBlock: (Error) -> Void = { [unowned self] error in
        let popup = PopupView(type: .cancel, labelString: error.localizedDescription)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    func handle(urlData: BitcoinUrlData) {
        if let amount = urlData.amount {
            userPaymentRequestProvider.createUserPaymentRequest(identifier: nil,
                                                                state: .waiting,
                                                                address: urlData.address,
                                                                amount: amount,
                                                                comment: "",
                                                                contactID: "",
                                                                completion: noOP,
                                                                failure: failureBlock)
        } else {
            let paymentRequest = PaymentRequest(address: urlData.address, amount: 0)
            router.showSendInputAddressView(paymentRequest: paymentRequest, userPaymentRequest: nil, failureTransaction: nil, back: #imageLiteral(resourceName: "background_black"))
        }
    }
}
