//
//  RequestSendProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RequestSendProvider: RequestSendProviderProtocol {
    
    let api: API
    let paymentRequestProvider: UserPaymentRequestProtocol
    let selfRequestProvider: SelfPaymentRequestProtocol
    let accountManager: AccountManager
    let messageSender: MessageSenderProtocol
    let wrapper: MessageWrapperProtocol
    
    init(api: API, paymentRequestProvider: UserPaymentRequestProtocol, selfRequestProvider: SelfPaymentRequestProtocol, accountManager: AccountManager, messageSender: MessageSenderProtocol, wrapper: MessageWrapperProtocol) {
        self.api = api
        self.wrapper = wrapper
        self.paymentRequestProvider = paymentRequestProvider
        self.selfRequestProvider = selfRequestProvider
        self.accountManager = accountManager
        self.messageSender = messageSender
    }
    
    func sendRequest(address: String, amount: Int64, comment: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void) {
        do {
            let selfPC = accountManager.getSelfPCString()
            let interval = String(Date().timeIntervalSince1970)
            let id = interval
            let request = UserPaymentRequest(identifier: id, state: .waiting, address: address, amount: amount, comment: comment, contactID: selfPC)
            let text = try paymentRequestProvider.convertToJson(request)
            let dataJson = JSON(parseJSON: text)
            let encodedData = try wrapper.wrap(dataJson, type: .request)
            messageSender.sendMessage(with: encodedData, to: contact, sendPush: true) { result in
                switch result {
                case .success(let success):
                    self.selfRequestProvider.createSelfPaymentRequest(identifier: request.identifier, state: .inProgress, address: address, amount: amount, comment: comment, contactID: contact.uniqueValue, completion: {
                        Logger.info("Self payment request created")
                        completion(.success(success))
                    }, failure: { error in
                        Logger.error("Self payment request creation error: \(error)")
                        completion(.failure(error))
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func declineRequest(identifier: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void) {
        do {
            let json = JSON(["id": identifier])
            let encodedData = try wrapper.wrap(json, type: .declineRequest)
            messageSender.sendMessage(with: encodedData, to: contact, sendPush: false, completion: { result in
                switch result {
                case .success(let success):
                    self.paymentRequestProvider.changeToState(identifier: identifier, state: .declined, completion: {
                        Logger.info("User payment request status changed to declined")
                        completion(.success(success))
                    }, failure: { error in
                        Logger.info("User payment request with id: \(identifier) can't change status")
                        completion(.failure(error))
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func cancelRequest(identifier: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void) {
        do {
            let json = JSON(["id": identifier])
            let encodedData = try wrapper.wrap(json, type: .cancelRequest)
            messageSender.sendMessage(with: encodedData, to: contact, sendPush: false, completion: { result in
                switch result {
                case .success(let success):
                    self.selfRequestProvider.changeStateToRejected(identifier: identifier, completion: {
                        Logger.info("Self payment request status changed to rejected")
                        completion(.success(success))
                    }, failure: { error in
                        Logger.info("Self payment request with id: \(identifier) can't change status")
                        completion(.failure(error))
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func confirmRequest(identifier: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void) {
        do {
            let json = JSON(["id": identifier])
            let encodedData = try wrapper.wrap(json, type: .confirmRequest)
            messageSender.sendMessage(with: encodedData, to: contact, sendPush: false, completion: { result in
                switch result {
                case .success(let success):
                    self.paymentRequestProvider.deleteUserPaymentRequest(identifier: identifier, completion: {
                        Logger.info("User payment request deleted")
                        completion(.success(success))
                    }, failure: { error in
                        Logger.info("Cannot delete User payment request with id: \(identifier)")
                        completion(.failure(error))
                    })
                case .failure(let error):
                    completion(.failure(error))
                }
            })
        } catch let error {
            completion(.failure(error))
        }
    }

}
