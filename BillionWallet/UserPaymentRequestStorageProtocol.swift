//
//  UserPaymentRequestStorageProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol UserPaymentRequestStorageProtocol: class {
    func getUserPaymentRequest(identifier: String,
                               completion: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void)
    func getUserPaymentRequest(url: URL,
                               completion: @escaping (String) -> Void,
                               failure: @escaping (Error) -> Void)
    func saveUserPaymentRequest(identifier: String,
                                jsonString: String,
                                completion: @escaping () -> Void,
                                failure: @escaping (Error) -> Void)
    func getListUserPaymentRequest(_ completion: @escaping ([URL]) -> Void, failure: @escaping (Error) -> Void)
    func deleteUserPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void)
}
