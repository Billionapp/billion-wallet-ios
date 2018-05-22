//
//  RequestSendProviderProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol RequestSendProviderProtocol {
    
    /// Send payment request
    func sendRequest(address: String, amount: Int64, comment: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void)
    
    /// Decline incoming payment request
    func declineRequest(identifier: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void)
    
    /// Cancel outcoming payment request
    func cancelRequest(identifier: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void)
    
    /// Confirm payment request
    func confirmRequest(identifier: String, contact: ContactProtocol, completion: @escaping (Result<String>) -> Void)
}
