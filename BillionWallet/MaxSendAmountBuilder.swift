//
//  MaxSendAmountBuilder.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol MaxSendAmountBuilder {
    func zeroMaxSendAmount() -> MaxSendAmount
    func buildMaxSendAmount() throws -> MaxSendAmount
}
