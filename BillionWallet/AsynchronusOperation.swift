//
//  AsynchronusOperation.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AsynchronousOperation: Operation {
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }
    
    enum State {
        case initialized
        case ready
        case executing
        case finished
    }
    
    let executeBlock: (@escaping (Result<String>) -> Void) -> Void
    let completion: (Result<String>) -> Void
    let queue: DispatchQueue
    
    init(executeBlock: @escaping (@escaping (Result<String>) -> Void) -> Void, completion: @escaping (Result<String>) -> Void, queue: DispatchQueue) {
        self.executeBlock = executeBlock
        self.completion = completion
        self.queue = queue
        super.init()
    }
    
    var state: State = .initialized {
        willSet {
            willChangeValue(forKey: "state")
        }
        didSet {
            didChangeValue(forKey: "state")
        }
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
    
    override var isReady: Bool {
        let ready = super.isReady
        if ready {
            state = .ready
        }
        return ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }
    
    override func main() {
        if isCancelled {
            state = .finished
        } else {
            state = .executing
            
            executeBlock { result in
                self.queue.async {
                    self.completion(result)
                }
                self.state = .finished
            }
        }
    }
}
