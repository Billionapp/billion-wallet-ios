//
//  PaymentRequestParser.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PaymentRequestParser: BitcoinSchemeParserProtocol {
    
    func parseUrl(_ url: URL) throws -> BitcoinUrlData {
        guard let paymentRequest = BRPaymentRequest(string: url.absoluteString),
            let foundAddress = paymentRequest.paymentAddress,
            foundAddress.isValidBitcoinAddress  else {
                throw BitcoinSchemeParserError.InvalidAddress
        }
        
        var amount: Int64?
        if paymentRequest.amount > 0 {
            amount = Int64(paymentRequest.amount)
        }

        return BitcoinUrlData(address: foundAddress, amount: amount)
    }
}
