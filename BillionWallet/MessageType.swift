//
//  MessageType.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

enum MessageType: String {
    case request = "cash_request"
    case declineRequest = "request_decline"
    case cancelRequest = "request_cancel"
    case confirmRequest = "request_confirm"
}
