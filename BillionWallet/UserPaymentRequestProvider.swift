//
//  UserPaymentRequestProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

let UserPaymentRequestEvent = Notification.Name(rawValue: "UserPaymentRequestWasChangedNotification")

class UserPaymentRequestProvider: UserPaymentRequestProtocol {
    private let storage: UserPaymentRequestStorageProtocol
    private let mapper: UserPaymentRequestMapperProtocol
    private let factory: UserPaymentRequestFactory
    
    var allUserPaymentRequests = [UserPaymentRequest]()
    
    init(storage: UserPaymentRequestStorageProtocol,
         mapper: UserPaymentRequestMapperProtocol,
         factory: UserPaymentRequestFactory) {
        
        self.storage = storage
        self.mapper = mapper
        self.factory = factory
        loadAllUserPaymentRequests({ (error) in
            Logger.error(error.localizedDescription)
        })
    }
    
    func isRequestExist(identifier: String)  -> Bool {
        return allUserPaymentRequests.contains(where: { $0.identifier ==  identifier})
    }
    
    func createUserPaymentRequest (identifier: String? = nil,
                                   state: UserPaymentRequestState,
                                   address: String,
                                   amount: Int64,
                                   comment: String,
                                   contactID: String,
                                   completion: @escaping () -> Void,
                                   failure: @escaping (Error) -> Void) {
        
        let upr = factory.createUserPaymentRequest(identifier: identifier,
                                                   state: state,
                                                   address: address,
                                                   amount: amount,
                                                   comment: comment,
                                                   contactID: contactID)
        
        var jsonString = ""
        do {
            jsonString = try mapper.encode(upr)
        } catch let error {
            failure(error)
            return
        }
        
        storage.saveUserPaymentRequest(identifier: upr.identifier,
                                       jsonString: jsonString,
                                       completion: { [unowned self] in
                                        self.allUserPaymentRequests.append(upr)
                                        NotificationCenter.default.post(name: UserPaymentRequestEvent, object: nil)
                                        completion()
        }) { (error) in
            failure(error)
        }
        
    }
    
    func loadAllUserPaymentRequests(_ failure: @escaping (Error) -> Void) {
        storage.getListUserPaymentRequest({ (urls) in
            DispatchQueue.global().async { [unowned self] in
                urls.forEach({ (url) in
                    self.storage.getUserPaymentRequest(url: url, completion: { (jsonString) in
                        do {
                            let userPaymentRequest = try self.mapper.decode(jsonString: jsonString)
                            self.addUprToCache(upr: userPaymentRequest)
                        } catch let error {
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
    
    private func addUprToCache(upr: UserPaymentRequest) {
        removeUprFromCache(identifier: upr.identifier)
        allUserPaymentRequests.append(upr)
        NotificationCenter.default.post(name: UserPaymentRequestEvent, object: nil)
    }
    
    private func removeUprFromCache(identifier: String) {
        if let index = allUserPaymentRequests.index(where: { $0.identifier == identifier }) {
            allUserPaymentRequests.remove(at: index)
        }
    }
    
    
    func deleteUserPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void) {
        
        storage.deleteUserPaymentRequest(identifier: identifier, completion: { [unowned self] in
            self.removeUprFromCache(identifier: identifier)
            NotificationCenter.default.post(name: UserPaymentRequestEvent, object: nil)
            Logger.info("UserPaymentRequest \(identifier) was removed")
            completion()
            }, failure: { (error) in
                failure(error)
        })
    }
    
    func deleteAllUserPaymentRequest(_ completion: @escaping () -> Void) {
        for upr in allUserPaymentRequests {
            self.deleteUserPaymentRequest(identifier: upr.identifier, completion: {
            }, failure: { (error) in
                Logger.error(error.localizedDescription)
            })
        }
        completion()
    }
    
    func changeToState(identifier: String,
                       state: UserPaymentRequestState,
                       completion: @escaping () -> Void,
                       failure: @escaping (Error) -> Void) {
        
        storage.getUserPaymentRequest(identifier: identifier, completion: { [unowned self] (jsonString) in
            var jsonStringChanged = ""
            do {
                var userPaymentRequest = try self.mapper.decode(jsonString: jsonString)
                userPaymentRequest.state = state
                jsonStringChanged = try self.mapper.encode(userPaymentRequest)
            } catch let error {
                failure(error)
                return
            }
            
            self.storage.saveUserPaymentRequest(identifier: identifier,
                                                jsonString: jsonStringChanged,
                                                completion: { [unowned self] in
                                                    for (i, userPaymentRequest) in self.allUserPaymentRequests.enumerated() where userPaymentRequest.identifier == identifier {
                                                        self.allUserPaymentRequests[i].state = state
                                                    }
                                                    NotificationCenter.default.post(name: UserPaymentRequestEvent, object: nil)
            }, failure: { (error) in
                failure(error)
            })
        }) { (error) in
            Logger.error(error.localizedDescription)
            failure(error)
        }
    }
  
    func convertToJson(_ request: UserPaymentRequest) throws -> String  {
        return try mapper.encode(request)
    }
    
    func restore(from json: String) throws -> UserPaymentRequest {
        return try mapper.decode(jsonString: json)
    }
    
}

