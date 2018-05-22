//
//  RateQueueProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol RateQueueProtocol {
    func addOperation(with timestamp: Int64, completion: @escaping (Result<[Rate]>) -> Void)
    func cancelAll()
}
