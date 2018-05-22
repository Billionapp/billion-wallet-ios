//
//  ContactIndex.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct ContactIndex: Codable {
    let pc: String
    let avatarData: Data?
    let queueId: String
    let name: String
    var fileNames: [String]
}
