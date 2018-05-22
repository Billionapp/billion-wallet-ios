//
//  TaskQueue.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TaskQueueProvider {
    fileprivate typealias OperationBlock = (@escaping (Result<String>) -> Void) -> Void
    
    private let retryInterval: Double = 30
    
    private let authorizationProvider: AuthorizationProvider
    private let accountProvider: AccountManager
    private let defaults: Defaults
    private let profileUpdater: ProfileUpdateManager
    private let pushConfigurator: PushConfigurator
    
    private let workingQueue: DispatchQueue
    private let operationQueue: OperationQueue
    private var isExecuting: Bool
    private var tasksToExecute: Set<TaskQueue>
    private var executingTasks: Set<TaskQueue>
    
    private var timer: Timer?
    
    init(authorizationProvider: AuthorizationProvider,
         accountProvider: AccountManager,
         defaults: Defaults,
         profileUpdater: ProfileUpdateManager,
         pushConfigurator: PushConfigurator) {
        
        self.authorizationProvider = authorizationProvider
        self.accountProvider = accountProvider
        self.defaults = defaults
        self.pushConfigurator = pushConfigurator
        self.profileUpdater = profileUpdater
        self.tasksToExecute = Set(defaults.taskQueue)
        self.executingTasks = Set()
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 3
        self.isExecuting = false
        self.workingQueue = DispatchQueue(label: "TaskQueueProviderQueue")
        
        start()
    }
    
    deinit {
        stop()
    }
    
    func start() {
        if isExecuting {
            Logger.debug("Task queue service is already running")
            return
        }
        Logger.info("Task queue service started")
        Logger.debug("Tasks in queue to execute: \(tasksToExecute), executing: \(executingTasks)")
        isExecuting = true
        operationQueue.isSuspended = false
        for task in tasksToExecute {
            startTask(task)
        }
    }
    
    func stop() {
        if !isExecuting {
            Logger.debug("Task queue service is not running")
            return
        }
        timer?.invalidate()
        timer = nil
        isExecuting = false
        operationQueue.isSuspended = true
        operationQueue.cancelAllOperations()
        operationQueue.isSuspended = false
        for task in executingTasks {
            tasksToExecute.insert(task)
        }
        executingTasks.removeAll()
        updateDefaults()
        Logger.info("Task queue service stopped")
    }
    
    func clear() {
        self.tasksToExecute.removeAll()
        self.executingTasks.removeAll()
        updateDefaults()
        Logger.debug("Task queue cleared")
    }
    
    func updateDefaults() {
        defaults.taskQueue = Array(tasksToExecute.union(executingTasks))
    }
    
    func addOperation(type: TaskQueue.OperationType) {
        let newTask = TaskQueue(operationType: type)
        Logger.debug("Trying to add task \"\(newTask)\"")
        if executingTasks.union(tasksToExecute).contains(newTask) {
            Logger.debug("Task queue already contains task \"\(newTask)\"")
            return
        }
        tasksToExecute.insert(newTask)
        updateDefaults()
        startTask(newTask)
    }
}

// MARK: - Private methods

extension TaskQueueProvider {
    private func taskHandler(forTask task: TaskQueue) -> ((Result<String>) -> Void) {
        return { [unowned self] result in
            switch result {
            case .success:
                Logger.info("Task \"\(task)\" succeeded.")
                self.removeTask(task)
            case .failure(let error):
                Logger.info("Task \"\(task)\" failed with error: \(error.localizedDescription). Retry in \(self.retryInterval)s")
                self.retryTask(task)
            }
        }
    }
    
    private func startTask(_ task: TaskQueue) {
        Logger.debug("Try to start task \"\(task)\"")
        guard isExecuting else {
            Logger.warn("Task queue service is not running yet. Task \"\(task)\" not started.")
            return
        }
        workingQueue.async {
            if self.executingTasks.contains(task) {
                Logger.debug("Task \"\(task)\" is already in executing list")
                return
            }
            let operationType = task.operationType
            if let operation = self.operation(for: operationType) {
                self.tasksToExecute.remove(task)
                self.executingTasks.insert(task)
                let asyncOperation = AsynchronousOperation(executeBlock: operation,
                                                           completion: self.taskHandler(forTask: task),
                                                           queue: self.workingQueue)
                self.operationQueue.addOperation(asyncOperation)
            } else {
                Logger.error("Could not get operation closure for task \"\(task)\"")
                self.retryTask(task)
            }
        }
    }
    
    private func removeTask(_ task: TaskQueue) {
        Logger.debug("Removing task \"\(task)\" from queue")
        workingQueue.async {
            self.tasksToExecute.remove(task)
            self.executingTasks.remove(task)
            self.updateDefaults()
        }
    }
    
    private func retryTask(_ task: TaskQueue) {
        Logger.debug("Posting task \"\(task)\" to retry")
        workingQueue.async {
            self.executingTasks.remove(task)
            self.tasksToExecute.insert(task)
            Helper.delay(self.retryInterval, queue: self.workingQueue, closure: {
                self.startTask(task)
            })
        }
    }
    
    private func operation(for type: TaskQueue.OperationType) -> (OperationBlock)? {
        switch type {
        case .register:
            guard let walletDigest = self.accountProvider.getOrCreateWalletDigest() else {
                return nil
            }
            return { [unowned self] result in
                self.authorizationProvider.register(walletDigest: walletDigest, completion: result)
            }

        case .updateProfile:
            guard let _ = self.accountProvider.getOrCreateWalletDigest() else {
                return nil
            }
            return { [unowned self] result in
                self.profileUpdater.updateUserProfile(completion: result)
            }
        case .pushConfig:
            guard let deviceToken = defaults.apnsToken else {
                return nil
            }
            return { [unowned self] result in
                self.pushConfigurator.configurePush(token: deviceToken, completion: result)
            }
        }
    }
}
