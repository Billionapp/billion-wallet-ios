//
//  AddressResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//


import Foundation

class AddressResolver: QrResolver {

    typealias LocalizedStrings = Strings.Scan
    private var nextResolver: QrResolver?
    private let callback: Callback
    private let walletProvider: WalletProvider
    
    init(callback: @escaping Callback, walletProvider: WalletProvider) {
        self.nextResolver = nil
        self.callback = callback
        self.walletProvider = walletProvider
    }
    
    @discardableResult
    func chain(_ next: QrResolver) -> QrResolver {
        self.nextResolver = next
        return next
    }
    
    func resolveQr(_ str: String) throws -> Callback {
        let wallet = try walletProvider.getWallet()
        guard wallet.containsAddress(str) == false else {
            throw QrResolveError.selfAddress(LocalizedStrings.selfAddress)
        }
        
        if isValidAddress(str) {
            return callback
        }
        
        if let next = nextResolver {
            return try next.resolveQr(str)
        } else {
            throw QrResolveError.invalidQr(LocalizedStrings.invalidQr)
        }
    }
    
    fileprivate func isValidAddress(_ addr: String) -> Bool {
        if let paymentRequest = BRPaymentRequest(string: addr),
            let foundAddress = paymentRequest.paymentAddress,
            foundAddress.isValidBitcoinAddress {
            return true
        } else {
            return false
        }
    }
}

