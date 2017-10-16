//
//  TaskQueue.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TaskQueueProvider {
    
    weak var authorizationProvider: AuthorizationProvider?
    weak var accountProvider: AccountManager?
    weak var defaults: Defaults?
    
    fileprivate let taskQueueProviderQueue = DispatchQueue(label: "TaskQueueProviderQueue")
    fileprivate let operationQueue: OperationQueue
    fileprivate var isExecuting = false
    fileprivate var taskQueue = Set<TaskQueue>() {
        didSet {
            defaults?.taskQueue = Array(taskQueue)
        }
    }
    
    var taskHandler: ((Result<String>) -> Void) {
        return { [unowned self] result in
            self.isExecuting = false
            
            switch result {
            case .success:
                Logger.info("Task queue stap successed")
                self.removeFirstTask()
                self.start()
            case .failure:
                Logger.info("Task queue stap failed. Retrying ...")
                Helper.delay(5, queue: self.taskQueueProviderQueue, closure: {
                    self.start()
                })
            }
        }
    }

    init(authorizationProvider: AuthorizationProvider, accountProvider: AccountManager, defaults: Defaults) {
        self.authorizationProvider = authorizationProvider
        self.accountProvider = accountProvider
        self.taskQueue = Set(defaults.taskQueue)
        self.defaults = defaults
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 1
        start()
    }
    
    @objc func start() {
        
        taskQueueProviderQueue.async {
            self.executeNextOperation()
        }
    }
    
    func addOperation(type: TaskQueue.OperationType) {
        let newTaskQueue = TaskQueue(operationType: type)
        taskQueue.insert(newTaskQueue)
        start()
    }
    
}

// MARK: - Private methods

extension TaskQueueProvider {
    
    fileprivate func executeNextOperation() {
        guard let operationType = taskQueue.first?.operationType, taskQueue.count != 0, !isExecuting else {
            return
        }
        
        isExecuting = true
        
        let asyncOperation = AsynchronousOperation(executeBlock: operation(for: operationType), completion: self.taskHandler, queue: taskQueueProviderQueue)
        operationQueue.addOperation(asyncOperation)
    }
    
    fileprivate func removeFirstTask() {
        if !taskQueue.isEmpty {
            taskQueue.removeFirst()
        }
    }
    
    fileprivate func operation(for type: TaskQueue.OperationType) -> ((@escaping (Result<String>) -> Void) -> Void) {
        
        switch type {
        case .registrationNew:
            
            return { [weak self] result in
                guard let walletDigest = self?.accountProvider?.currentWalletDigest else {
                    return
                }
                self?.authorizationProvider?.registerNewAccount(walletDigest: walletDigest, completion: result)
            }
            
        case .registrationRestore:
            
            return { [weak self] result in
                guard let walletDigest = self?.accountProvider?.currentWalletDigest else {
                    return
                }
                self?.authorizationProvider?.restoreRegistration(walletDigest: walletDigest, completion: result)
            }
            
        }
        
    }
    
}
