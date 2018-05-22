//
//  SelfPaymentRequestMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

class SelfPaymentRequestMapper: SelfPaymentRequestMapperProtocol {
    
    func decode(jsonString json: String) throws -> (SelfPaymentRequest) {
        let data = json.data(using: .utf8)
        return try JSONDecoder().decode(SelfPaymentRequest.self, from: data!)
    }
    
    func encode(_ selfPaymentRequest: SelfPaymentRequest) throws -> (String) {
        let data = try JSONEncoder().encode(selfPaymentRequest)
        return String(data: data, encoding: .utf8)!
    }
}
