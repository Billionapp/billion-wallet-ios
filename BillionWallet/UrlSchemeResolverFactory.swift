//
//  UrlSchemeResolverFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class UrlSchemeResolverFactory {
    
    private let router: MainRouter
    private let accountProvider: AccountManager
    private let userPaymentRequestProvider: UserPaymentRequestProtocol
    private let walletProvider: WalletProvider
    
    init(userPaymentRequestProvider: UserPaymentRequestProtocol,
         router: MainRouter,
         accountProvider: AccountManager,
         walletProvider: WalletProvider) {
        
        self.router = router
        self.accountProvider = accountProvider
        self.userPaymentRequestProvider = userPaymentRequestProvider
        self.walletProvider = walletProvider
    }

    func createUrlSchemeResolver(from url: URL) -> SchemeResolverProtocol {
    
        guard let scheme = url.scheme else {
            return FailResolver(reason: .unknownUrl)
        }
        
        guard !walletProvider.noWallet else {
            return FailResolver(reason: .noWallet)
        }
                
        if scheme == "bitcoin" && url.host != nil {
            let bitcoinParser = BitcoinSchemeParser()
            let bitcoinHandler = BitcoinUrlHandler(userPaymentRequestProvider: userPaymentRequestProvider, router: router)
            return BitcoinSchemeResolver(parser: bitcoinParser, handler: bitcoinHandler)
        } else if BRPaymentRequest(string: url.absoluteString) != nil {
            let paymentReqParcer = PaymentRequestParser()
            let paymentReqHandler = BitcoinUrlHandler(userPaymentRequestProvider: userPaymentRequestProvider, router: router)
            return PaymentRequestResolver(parser: paymentReqParcer, handler: paymentReqHandler)
        } else if scheme == "billion" {
            let billionParser = BillionSchemeParser()
            let billionHandler = BillionUrlHandler(router: router, accountProvider: accountProvider)
            return BillionSchemeResolver(billionParser: billionParser, billionHandler: billionHandler)
        } else {
            return FailResolver(reason: .unknownUrl)
        }
    }
}

