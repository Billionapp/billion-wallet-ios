//
//  SelfPaymentRequestProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol SelfPaymentRequestProtocol: class {
    var allSelfPaymentRequests: [SelfPaymentRequest] { get }
    
    /// Set identifier to nil and identifier will generates automaticaly
    func createSelfPaymentRequest (identifier: String?,
                                   state: SelfPaymentRequestState,
                                   address: String,
                                   amount: Int64,
                                   comment: String,
                                   contactID: String,
                                   completion: @escaping () -> Void,
                                   failure: @escaping (Error) -> Void)
    func loadAllSelfPaymentRequests(_ failure: @escaping (Error) -> Void)
    func deleteSelfPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void)
    func deleteAllSelfPaymentRequest(_ completion: @escaping () -> Void)
    func changeStateToRejected(identifier: String,
                               completion: @escaping () -> Void,
                               failure: @escaping (Error) -> Void)
    func convertToJson(_ request: SelfPaymentRequest) throws -> String
    func restore(from json: String) throws -> SelfPaymentRequest
}
