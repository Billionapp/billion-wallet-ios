//
//  UserPaymentRequestMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class UserPaymentRequestMapper: UserPaymentRequestMapperProtocol {
    
    func decode(jsonString json: String) throws -> UserPaymentRequest {
        let data = json.data(using: .utf8)
        return try JSONDecoder().decode(UserPaymentRequest.self, from: data!)
    }
    
    func encode(_ userPaymentRequest: UserPaymentRequest) throws -> (String) {
        let data = try JSONEncoder().encode(userPaymentRequest)
        return String(data: data, encoding: .utf8)!
    }
}
