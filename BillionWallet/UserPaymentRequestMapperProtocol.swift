//
//  UserPaymentRequestMapperProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol UserPaymentRequestMapperProtocol: class {
    func decode(jsonString json: String) throws -> (UserPaymentRequest)
    func encode(_ UserPaymentRequest: UserPaymentRequest) throws -> (String)
}
