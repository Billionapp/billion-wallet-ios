//
//  MessageSenderProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MessageSenderProtocol {
    func sendMessage(with data: Data, to contact: ContactProtocol, sendPush: Bool, completion: @escaping (Result<String>) -> Void)
}
