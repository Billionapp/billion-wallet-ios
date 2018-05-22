//
//  TxRelationDetectorProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxRelationDetectorProtocol {
    
    func detect(_ transaction: Transaction, _ contact: ContactProtocol) -> TxRelation
    
    @discardableResult
    func chain(_ next: TxRelationDetectorProtocol) -> TxRelationDetectorProtocol
}
