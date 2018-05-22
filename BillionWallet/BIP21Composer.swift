//
//  BIP21Composer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol URIComposer {
    func getPaymentRequestURI(with amount: UInt64 , address: String, withSlashes: Bool) -> String
    func getContactURI(with pc: String, contactName: String) -> String
}

class BillionUriComposer: URIComposer {

    private var bitcoinUrlScheme = "bitcoin://"
    private var billionUrlScheme = "billion://"
    private var bitcoinUrlNoSlash = "bitcoin:"
    
    private func btcAmount(_ amt: UInt64) -> Decimal {
        return Decimal(amt)/Decimal(1e8)
    }
    
    // MARK: - URIComposer
    func getPaymentRequestURI(with amount: UInt64 , address: String, withSlashes: Bool) -> String {
        
        let amt = btcAmount(amount)
        let scheme = withSlashes ? bitcoinUrlScheme : bitcoinUrlNoSlash
        return amt == 0 ? "\(scheme)\(address)" : "\(scheme)\(address)?amount=\(amt)"
    }
    
    func getContactURI(with pc: String, contactName: String) -> String {
        let encodeContact = contactName.addingPercentEncoding(withAllowedCharacters: .letters)
        return "\(billionUrlScheme)contact/\(pc)?name=\(encodeContact ?? "")"
    }
}

