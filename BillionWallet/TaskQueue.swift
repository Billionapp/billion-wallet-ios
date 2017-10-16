//
//  TaskQueue.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct TaskQueue {
    
    enum OperationType: Int, CodingKey {
        case registrationNew
        case registrationRestore
    }
   
    let operationType: OperationType
}

// MARK: - Equatable

extension TaskQueue: Hashable {
    
    static func ==(lhs: TaskQueue, rhs: TaskQueue) -> Bool {
        return lhs.operationType.rawValue == rhs.operationType.rawValue
    }
    
    var hashValue: Int {
        return operationType.hashValue
    }

}

