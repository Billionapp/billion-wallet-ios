//
//  MessageStorageProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/01/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MessageStorageProtocol {
    func store(json: JSON) throws
}
