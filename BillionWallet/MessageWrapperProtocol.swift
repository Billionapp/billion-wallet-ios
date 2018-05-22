//
//  MessageWrapperProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MessageWrapperProtocol {
    func wrap(_ dataJson: JSON, type: MessageType) throws -> Data
    func unwrap(_ data: Data) throws -> (type: MessageType, json: JSON)
}
