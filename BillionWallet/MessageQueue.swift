//
//  MessageQueue.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum MessageQueueError: Error {
    case mappingError
}

struct MessageQueue {
    let queueId: String
    let filenames: [String]
    
    init?(object: (queueId: String, contents: JSON)) {
        guard
            let filenames = object.contents.arrayObject as? [String] else {
            return nil
        }
        self.queueId = object.queueId
        self.filenames = filenames
    }
}
