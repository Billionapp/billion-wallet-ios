//
//  FailureTransactionProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

let FailureTransactionsEvent = Notification.Name(rawValue: "FailureTransactionsWasChangedNotification")

class FailureTxProviderA: FailureTxProtocol {
    private let storage: FailureTxAsyncStorageProtocol
    private let mapper: FailureTxMapperProtocol
    private let factory: FailureTxFactory
    
    var allFailureTxs = [FailureTx]()
    
    init(storage: FailureTxAsyncStorageProtocol,
         mapper: FailureTxMapperProtocol,
         factory: FailureTxFactory) {
        
        self.storage = storage
        self.mapper = mapper
        self.factory = factory
        loadAllFailureTxs({ (error) in
            Logger.error(error.localizedDescription)
        })
    }
    
    func createFailureTx (address: String,
                          amount: UInt64,
                          fee: UInt64,
                          comment: String,
                          contactID: String,
                          completion: @escaping () -> Void,
                          failure: @escaping (Error) -> Void) {
        
        let tx = factory.createFailureTx(address: address,
                                         amount: amount,
                                         fee: fee,
                                         comment: comment,
                                         contactID: contactID)
        
        var jsonString = ""
        do {
            jsonString = try mapper.encode(tx)
        } catch let error {
            failure(error)
            return
        }
        
        storage.saveFailureTx(identifier: tx.identifier,
                              jsonString: jsonString,
                              completion: { [unowned self] in
                                
                                self.allFailureTxs.append(tx)
                                NotificationCenter.default.post(name: FailureTransactionsEvent, object: nil)
                                completion()
        }) { (error) in
            failure(error)
        }
        
    }
    
    func loadAllFailureTxs(_ failure: @escaping (Error) -> Void) {
        storage.getListFailureTx({ (urls) in
            DispatchQueue.global().async { [unowned self] in
                urls.forEach({ (url) in
                    self.storage.getFailureTx(url: url, completion: { (jsonString) in
                        do {
                            let failureTx = try self.mapper.decode(jsonString: jsonString)
                            self.addTxToCache(ftx: failureTx)
                        } catch let error {
                            // TODO: Remove failure tx from storage
                            Logger.error(error.localizedDescription)
                        }
                    }, failure: { (error) in
                        Logger.error(error.localizedDescription)
                    })
                })
            }
        }) { (error) in
            failure(error)
        }
    }
    
    private func addTxToCache(ftx: FailureTx) {
        removeTxFromCache(identifier: ftx.identifier)
        allFailureTxs.append(ftx)
        NotificationCenter.default.post(name: FailureTransactionsEvent, object: nil)
    }
    
    private func removeTxFromCache(identifier: String) {
        if let index = allFailureTxs.index(where: { $0.identifier == identifier }) {
            allFailureTxs.remove(at: index)
        }
    }
    
    
    func deleteFailureTx(identifier: String,
                         completion: @escaping () -> Void,
                         failure: @escaping (Error) -> Void) {
        
        storage.deleteFailureTx(identifier: identifier, completion: { [unowned self] in
            self.removeTxFromCache(identifier: identifier)
            NotificationCenter.default.post(name: FailureTransactionsEvent, object: nil)
            Logger.info("Failed Transaction \(identifier) was removed")
            completion()
            }, failure: { (error) in
                failure(error)
        })
    }
    
    func deleteAllFailureTxs(_ completion: @escaping () -> Void) {
        for tx in allFailureTxs {
            self.deleteFailureTx(identifier: tx.identifier, completion: {
            }, failure: { (error) in
                Logger.error(error.localizedDescription)
            })
        }
        completion()
    }
}
