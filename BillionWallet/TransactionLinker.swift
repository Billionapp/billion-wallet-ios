//
//  TransactionLinker.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TransactionLinkerProtocol: class {
    func link(relations: [TxRelation], completion: (_ contact: ContactProtocol) -> Void)
}

class TransactionLinker {
    
    private let contactsProvider: ContactsProvider
    
    init(contactProvider: ContactsProvider) {
        self.contactsProvider = contactProvider
    }
}

extension TransactionLinker: TransactionLinkerProtocol {
    func link(relations: [TxRelation], completion: (_ contact: ContactProtocol) -> Void) {
        var txHashes: Set <String> = []
        var notifTxHash: String?
        
        guard var contact = relations.first?.contact else {
            return
        }
        
        for relation in relations {
            let type = relation.relationType
            let txhash = relation.tx.txHash.data.hex
            
            switch type {
            case .notifTxFrom: break
            case .notifTxTo:
                if relation.contact.isNotificationTxNeededToSend {
                    txHashes.insert(txhash)
                    notifTxHash = txhash
                }
            case .regularTxFrom: txHashes.insert(txhash)
            case .regularTxTo: txHashes.insert(txhash)
            case .unknownType: break
            }
        }
        
        for txHash in  txHashes {
            contact.txHashes.insert(txHash)
        }
        
        if let notifTx = notifTxHash {
            contact.notificationTxHash = notifTx
        }
        
        completion(contact)
    }
}

extension Notification.Name {
    public static let transactionsLinkedToContact = Notification.Name("transactionsLinkedToContact")
}
