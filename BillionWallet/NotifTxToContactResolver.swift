//
//  NotifTxToContactResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class NotifTxToContactResolver: TxRelationDetectorProtocol {
    
    private var nextResolver: TxRelationDetectorProtocol?
    
    func detect(_ transaction: Transaction, _ contact: ContactProtocol) -> TxRelation {
        let unknowRelation = TxRelation(relationType: .unknownType, tx: transaction, contact: contact)
        let notifToContactRelation: TxRelation
        
        if let notifAddress = contact.getNotificationAddress() {
            let outputAddresses = transaction.outputAddresses
            if outputAddresses.contains(notifAddress) {
                notifToContactRelation = TxRelation(relationType: .notifTxTo, tx: transaction, contact: contact)
                return notifToContactRelation
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
