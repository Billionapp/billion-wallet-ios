//
//  ICloudAttach.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum ICloudAttach {
    case image(data: Data?)
    
    var fileName: String {
        switch self {
        case .image:
            return type + ".jpg"
        }
    }
    
    var type: String {
        return "image"
    }
    
    var data: Data? {
        switch self {
        case .image(let data):
            return data
        }
    }
}

