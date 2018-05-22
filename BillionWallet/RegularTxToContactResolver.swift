//
//  RegularTxToResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RegularTxToContactResolver : TxRelationDetectorProtocol {
    
    private var nextResolver: TxRelationDetectorProtocol?
    
    private func isIntersection(firstArray: [String], secondArray: [String]) -> Bool {
        let set1 = Set(firstArray)
        let set2 = Set(secondArray)
        let intersection = set1.intersection(set2)
        return intersection.count != 0 ? true : false
    }
    
    func detect(_ transaction: Transaction, _ contact: ContactProtocol) -> TxRelation {
        let unknowRelation = TxRelation(relationType: .unknownType, tx: transaction, contact: contact)
        let regularTxToContactRelation: TxRelation
        let pregeneratedSendAddresses = contact.getSendAddresses()
        
        if pregeneratedSendAddresses.count != 0 {
            let outputAddresses = transaction.outputAddresses
            if isIntersection(firstArray: outputAddresses, secondArray: pregeneratedSendAddresses) {
                regularTxToContactRelation = TxRelation(relationType: .regularTxTo, tx: transaction, contact: contact)
                return regularTxToContactRelation
            }
        }
        
        guard let next = nextResolver else { return unknowRelation }
        return next.detect(transaction, contact)
    }
    
    func chain(_ next: TxRelationDetectorProtocol) -> TxRelationDetectorProtocol {
        self.nextResolver = next
        return next
    }
}
