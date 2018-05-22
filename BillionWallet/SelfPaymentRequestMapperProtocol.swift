//
//  SelfPaymentRequestMapperProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol SelfPaymentRequestMapperProtocol: class {
    func decode(jsonString json: String) throws -> (SelfPaymentRequest)
    func encode(_ selfPaymentRequest: SelfPaymentRequest) throws -> (String)
}
