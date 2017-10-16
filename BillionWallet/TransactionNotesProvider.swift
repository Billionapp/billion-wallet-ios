//
//  TransactionNotesProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TransactionNotesProvider {
    let tx: BRTransaction
    
    init(tx: BRTransaction) {
        self.tx = tx
    }
    
    func setUserNote(with str: String) {
        let data = UInt256S(tx.txHash).data
        let args: [CVarArg] = [data as CVarArg]
        let txCD = BRTxMetadataEntity.objects(matching: "txHash == %@ ", arguments: getVaList(args)).first as! BRTxMetadataEntity
        txCD.setValue(tx.userNote, forKey: "userNote")
        txCD.setValue(str, forKey: "userNote")
        BRTxMetadataEntity.saveContext()
    }
}
