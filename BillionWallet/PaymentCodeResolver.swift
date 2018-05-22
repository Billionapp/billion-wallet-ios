//
//  PaymentCodeResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//


import Foundation

class PaymentCodeResolver: QrResolver {
    
    typealias LocalizedStrings = Strings.Scan
    
    private var nextResolver: QrResolver?
    private let selfPC: String
    private let callback: Callback
    
    init(accountProvider: AccountManager, callback: @escaping Callback) {
        self.nextResolver = nil
        self.selfPC = accountProvider.getSelfPCString()
        self.callback = callback
    }
    
    @discardableResult
    func chain(_ next: QrResolver) -> QrResolver {
        self.nextResolver = next
        return next
    }
    
    func resolveQr(_ str: String) throws -> Callback {
        
        if selfPC == str {
            throw QrResolveError.selfPC(Strings.Scan.selfPC)
        }
        
        if let pc = try? PaymentCode(with: str) {
            Logger.debug(pc.serializedString)
            return callback
        }
        
        if let next = nextResolver {
            return try next.resolveQr(str)
        } else {
            throw QrResolveError.invalidQr(LocalizedStrings.invalidQr)
        }
    }
}
