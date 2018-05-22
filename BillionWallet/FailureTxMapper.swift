//
//  FailureTransactionMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class FailureTxMapper: FailureTxMapperProtocol {
    
    func decode(jsonString json: String) throws -> (FailureTx) {        
        let data = json.data(using: .utf8)
        return try JSONDecoder().decode(FailureTx.self, from: data!)
    }
    
    func encode(_ failureTx: FailureTx) throws -> (String) {
        let data = try JSONEncoder().encode(failureTx)
        return String(data: data, encoding: .utf8)!
    }
}
