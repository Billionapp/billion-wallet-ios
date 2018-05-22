//
//  TaskQueue.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct TaskQueue: CustomStringConvertible {
    enum OperationType: Int, CodingKey {
        case register
        case updateProfile
        case pushConfig
    }
   
    let operationType: OperationType
    
    var description: String {
        switch operationType {
        case .register: return "Registration"
        case .updateProfile: return "Profile update"
        case .pushConfig: return "Configure push notifications"
        }
    }
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

