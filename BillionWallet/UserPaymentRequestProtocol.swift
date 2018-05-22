//
//  UserPaymentRequestProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol UserPaymentRequestProtocol: class {
    var allUserPaymentRequests: [UserPaymentRequest] { get }
    
    func isRequestExist(identifier: String)  -> Bool
    /// Set identifier to nil and identifier will generates automaticaly
    func createUserPaymentRequest (identifier: String?,
                                   state: UserPaymentRequestState,
                                   address: String,
                                   amount: Int64,
                                   comment: String,
                                   contactID: String,
                                   completion: @escaping () -> Void,
                                   failure: @escaping (Error) -> Void)
    func loadAllUserPaymentRequests(_ failure: @escaping (Error) -> Void)
    func deleteUserPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void)
    func deleteAllUserPaymentRequest(_ completion: @escaping () -> Void)
    func changeToState(identifier: String,
                       state: UserPaymentRequestState,
                       completion: @escaping () -> Void,
                       failure: @escaping (Error) -> Void)
    func convertToJson(_ request: UserPaymentRequest) throws -> String
    func restore(from json: String) throws -> UserPaymentRequest
}
