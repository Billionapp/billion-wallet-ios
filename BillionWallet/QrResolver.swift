//
//  QrResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//


import Foundation

enum ResolveString {
    case address, pc, trash(String?)
}

enum QrResolveError: LocalizedError {
    case selfPC(String)
    case invalidQr(String)
    case selfAddress(String)
    case unknownError(String)
}

extension QrResolveError {
    var errorDescription: String? {
        switch self {
        case .selfPC(let err):
            return err
        case .invalidQr(let err):
            return err
        case .selfAddress(let err):
            return err
        case .unknownError(let err):
            return err
        }
    }
}

protocol QrResolver {
    
    typealias Callback = (String) -> Void
    
    func resolveQr(_ str: String) throws -> Callback
    
    @discardableResult
    func chain(_ next: QrResolver) -> QrResolver
}
