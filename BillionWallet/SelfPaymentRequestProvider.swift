//
//  SelfPaymentRequestProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

let SelfPaymentRequestEvent = Notification.Name(rawValue: "SelfPaymentRequestWasChangedNotification")

class SelfPaymentRequestProvider: SelfPaymentRequestProtocol {
    private let storage: SelfPaymentRequestStorageProtocol
    private let mapper: SelfPaymentRequestMapperProtocol
    private let factory: SelfPaymentRequestFactory
    
    var allSelfPaymentRequests = [SelfPaymentRequest]()
    
    init(storage: SelfPaymentRequestStorageProtocol,
         mapper: SelfPaymentRequestMapperProtocol,
         factory: SelfPaymentRequestFactory) {
        
        self.storage = storage
        self.mapper = mapper
        self.factory = factory
        loadAllSelfPaymentRequests({ (error) in
            Logger.error(error.localizedDescription)
        })
    }
    
    func createSelfPaymentRequest (identifier: String? = nil,
                                   state: SelfPaymentRequestState,
                                   address: String,
                                   amount: Int64,
                                   comment: String,
                                   contactID: String,
                                   completion: @escaping () -> Void,
                                   failure: @escaping (Error) -> Void) {
        
        let spr = factory.createSelfPaymentRequest(identifier: identifier,
                                                   state: state,
                                                   address: address,
                                                   amount: amount,
                                                   comment: comment,
                                                   contactID: contactID)
        
        var jsonString = ""
        do {
            jsonString = try mapper.encode(spr)
        } catch let error {
            failure(error)
            return
        }
        
        storage.saveSelfPaymentRequest(identifier: spr.identifier,
                                       jsonString: jsonString,
                                       completion: { [unowned self] in
                                        self.allSelfPaymentRequests.append(spr)
                                        NotificationCenter.default.post(name: SelfPaymentRequestEvent, object: nil)
                                        completion()
        }) { (error) in
            failure(error)
        }
        
    }
    
    func loadAllSelfPaymentRequests(_ failure: @escaping (Error) -> Void) {
        storage.getListSelfPaymentRequest({ (urls) in
            DispatchQueue.global().async { [unowned self] in
                urls.forEach({ (url) in
                    self.storage.getSelfPaymentRequest(url: url, completion: { (jsonString) in
                        do {
                            let selfPaymentRequest = try self.mapper.decode(jsonString: jsonString)
                            self.addSprToCache(spr: selfPaymentRequest)
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
    
    private func addSprToCache(spr: SelfPaymentRequest) {
        removeSprFromCache(identifier: spr.identifier)
        allSelfPaymentRequests.append(spr)
        NotificationCenter.default.post(name: SelfPaymentRequestEvent, object: nil)
    }
    
    private func removeSprFromCache(identifier: String) {
        if let index = allSelfPaymentRequests.index(where: { $0.identifier == identifier }) {
            allSelfPaymentRequests.remove(at: index)
        }
    }
    
    
    func deleteSelfPaymentRequest(identifier: String,
                                  completion: @escaping () -> Void,
                                  failure: @escaping (Error) -> Void) {
        
        storage.deleteSelfPaymentRequest(identifier: identifier, completion: { [unowned self] in
            self.removeSprFromCache(identifier: identifier)
            NotificationCenter.default.post(name: SelfPaymentRequestEvent, object: nil)
            Logger.info("SelfPaymentRequest \(identifier) was removed")
            completion()
            }, failure: { (error) in
                failure(error)
        })
    }
    
    func deleteAllSelfPaymentRequest(_ completion: @escaping () -> Void) {
        for spr in allSelfPaymentRequests {
            self.deleteSelfPaymentRequest(identifier: spr.identifier, completion: {
            }, failure: { (error) in
                Logger.error(error.localizedDescription)
            })
        }
        completion()
    }
    
    func changeStateToRejected(identifier: String,
                               completion: @escaping () -> Void,
                               failure: @escaping (Error) -> Void) {
        
        storage.getSelfPaymentRequest(identifier: identifier, completion: { [unowned self] (jsonString) in
            var jsonStringChanged = ""
            do {
                var selfPaymentRequest = try self.mapper.decode(jsonString: jsonString)
                selfPaymentRequest.state = SelfPaymentRequestState.rejected
                jsonStringChanged = try self.mapper.encode(selfPaymentRequest)
            } catch let error {
                failure(error)
                return
            }
            
            self.storage.saveSelfPaymentRequest(identifier: identifier,
                                                jsonString: jsonStringChanged,
                                                completion: {
                                                    for (i, userPaymentRequest) in self.allSelfPaymentRequests.enumerated() where userPaymentRequest.identifier == identifier {
                                                        self.allSelfPaymentRequests[i].state = .rejected
                                                    }
                                                    NotificationCenter.default.post(name: SelfPaymentRequestEvent, object: nil)
            }, failure: { (error) in
                failure(error)
            })
        }) { (error) in
            Logger.error(error.localizedDescription)
            failure(error)
        }
    }
    
    func convertToJson(_ request: SelfPaymentRequest) throws -> String  {
        return try mapper.encode(request)
    }
    
    func restore(from json: String) throws -> SelfPaymentRequest {
        return try mapper.decode(jsonString: json)
    }
}
