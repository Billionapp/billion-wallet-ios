//
//  TransactionNotesProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class TransactionNotesProvider {
    
    func setUserNote(with str: String, for txHash: UInt256S) {
        let data = txHash.data
        let args: [CVarArg] = [data as CVarArg]
        if let txCD = BRTxMetadataEntity.objects(matching: "txHash == %@ ", arguments: getVaList(args)).first as? BRTxMetadataEntity {
            txCD.setValue(str, forKey: "userNote")
            BRTxMetadataEntity.saveContext()
        }
    }
    
    func getUserNote(for txHash: UInt256S) -> String? {
        let args: [CVarArg] = [txHash.data as CVarArg]
        let txCD = BRTxMetadataEntity.objects(matching: "txHash == %@ ", arguments: getVaList(args)).first as! BRTxMetadataEntity
        return txCD.userNote
    }
}
