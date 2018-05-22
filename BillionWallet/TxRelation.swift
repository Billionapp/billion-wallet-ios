//
//  TxRelation.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum RelationType {
    case notifTxTo
    case notifTxFrom
    case regularTxTo
    case regularTxFrom
    case unknownType
}

struct TxRelation {
    let relationType: RelationType
    let tx: Transaction
    let contact: ContactProtocol
}
