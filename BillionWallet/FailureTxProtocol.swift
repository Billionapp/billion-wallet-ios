//
//  FailureTxProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol FailureTxProtocol: class {
    var allFailureTxs: [FailureTx] { get }
    
    func createFailureTx (address: String,
                          amount: UInt64,
                          fee: UInt64,
                          comment: String,
                          contactID: String,
                          completion: @escaping () -> Void,
                          failure: @escaping (Error) -> Void)
    func loadAllFailureTxs(_ failure: @escaping (Error) -> Void)
    func deleteFailureTx(identifier: String, completion: @escaping () -> Void, failure: @escaping (Error) -> Void)
    func deleteAllFailureTxs(_ completion: @escaping () -> Void)
}
