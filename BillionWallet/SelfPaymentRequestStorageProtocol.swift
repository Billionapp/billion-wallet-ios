//
//  SelfPaymentRequestStorageProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol SelfPaymentRequestStorageProtocol: class {
    func getSelfPaymentRequest(identifier: String,
                               completion: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void)
    func getSelfPaymentRequest(url: URL,
                               completion: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void)
    func saveSelfPaymentRequest(identifier: String,
                                jsonString: String,
                                completion: @escaping () -> Void,
                                failure: @escaping (Error) -> Void)
    func getListSelfPaymentRequest(_ completion: @escaping ([URL]) -> Void, failure: @escaping (Error) -> Void)
    func deleteSelfPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void)
}
