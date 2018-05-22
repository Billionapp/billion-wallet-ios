//
//  NotifTxFromContactResolver.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class NotifTxFromContactResolver: TxRelationDetectorProtocol {

    private var nextResolver: TxRelationDetectorProtocol?
    private let accountProvider: AccountManager
    
    init(accountProvider: AccountManager) {
        self.accountProvider = accountProvider
    }
    
    private func getPaymentCodeFrom(_ transaction: Transaction) throws  -> String {
        let selfPCPrivData = accountProvider.getSelfCPPriv()
        let selfPCPriv = try PrivatePaymentCode(priv: selfPCPrivData)
        let recoveredPC = try selfPCPriv.recoverCode(from: transaction.brTransaction)
        return recoveredPC.serializedString
    }
    
    func detect(_ transaction: Transaction, _ contact: ContactProtocol) -> TxRelation {
        let unknowRelation = TxRelation(relationType: .unknownType, tx: transaction, contact: contact)
        let notifTxFromContactRelation: TxRelation

        if let recoveredPC = try? getPaymentCodeFrom(transaction) {

            if recoveredPC == contact.uniqueValue {
                Logger.debug("notification tx: \(transaction.txHash.data.hex) from: \(contact.displayName)")
                notifTxFromContactRelation = TxRelation(relationType: .notifTxFrom, tx: transaction, contact: contact)
                return notifTxFromContactRelation
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
