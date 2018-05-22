//
//  ObjectMapper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol FailureTxMapperProtocol: class {
    func encode(_ failureTx: FailureTx) throws -> String
    func decode(jsonString json: String) throws -> FailureTx
}
