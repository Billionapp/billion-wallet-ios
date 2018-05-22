//
//  UnknownResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// Leaf resolver to pass PCFailed string as error
class PCFailResolver: QrResolver {
    
    typealias LocalizedStrings = Strings.Scan

    @discardableResult
    func chain(_ next: QrResolver) -> QrResolver {
        return self
    }
    
    func resolveQr(_ str: String) throws -> Callback {
        throw QrResolveError.invalidQr(LocalizedStrings.incorrectPC)
    }
    
}
