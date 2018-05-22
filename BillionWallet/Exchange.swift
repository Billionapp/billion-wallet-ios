//
//  Exchange.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct Exchange: Codable {
    let id: String
    let title: String
    let icon_base64: String
    let ref_url: String
    
    init(json: JSON) {
        self.id = json["id"].stringValue
        self.title = json["title"].stringValue
        self.icon_base64 = json["icon_base64"].stringValue
        self.ref_url = json["ref_url"].stringValue
    }
}
