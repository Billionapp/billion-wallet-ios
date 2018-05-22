//
//  RateQueue.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RateQueue: RateQueueProtocol {
    
    typealias OperationBlock = (@escaping (Result<[Rate]>) -> Void) -> Void
    
    private let api: API
    private let queue: DispatchQueue
    private let operationQueue: OperationQueue
    private var index = Set<Int64>()
    
    init(api: API) {
        self.api = api
        self.queue = DispatchQueue(label: "RateQueue")
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 5
    }
    
    func addOperation(with timestamp: Int64, completion: @escaping (Result<[Rate]>) -> Void) {
        
        guard !isInQueue(timestamp) else {
            return
        }
        index.insert(timestamp)
        
        let newOperation = AsynchronousOperation(executeBlock: operation(with: timestamp),
                                                 completion: completion,
                                                 queue: queue)
        operationQueue.addOperation(newOperation)
    }
    
    // MARK: - Privates
    
    private func operation(with timestamp: Int64) -> OperationBlock {
        return { [unowned self] result in
            let supportedRates: [String] = CurrencyFactory.allowedCurrenies().flatMap({ $0.code })
            self.api.getHistoricalRate(supportedRates: supportedRates, timestamp: timestamp, completion: result)
        }
    }
    
    private func isInQueue(_ timestamp: Int64) -> Bool {
        return index.contains(timestamp)
    }

    func cancelAll() {
        self.operationQueue.cancelAllOperations()
    }
}
