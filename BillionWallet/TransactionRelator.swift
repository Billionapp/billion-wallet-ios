//
//  TransactionRelator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TransactionRelatorProtocol: class {
    func detectRelated(_ txs: [Transaction], for contact: ContactProtocol) -> [TxRelation]
}

class TransactionRelator {
    
    private let accountProvider: AccountManager

    private func createChain() -> TxRelationDetectorProtocol {
        let notifToContact = NotifTxToContactResolver()
        let notifFromContact = NotifTxFromContactResolver(accountProvider: accountProvider)
        let regularToContact = RegularTxToContactResolver()
        let regularFromContact = RegularTxFromContactResolver()
        notifToContact.chain(notifFromContact).chain(regularToContact).chain(regularFromContact)
        return notifToContact
    }
    
    init(accountProvier: AccountManager) {
        self.accountProvider = accountProvier
    }
}

extension TransactionRelator: TransactionRelatorProtocol {
    func detectRelated(_ txs: [Transaction], for contact: ContactProtocol) -> [TxRelation] {
        var outputArray = [TxRelation]()
        for tx in txs {
            outputArray.append(createChain().detect(tx, contact))
        }
        
        return outputArray
    }
}
