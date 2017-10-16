//
//  Fee.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class Fee {
    var size: FeeSize?
    var satPerByte: Int?
    var confirmTime: Int?
    
    init(size: FeeSize, satPerByte: Int, confirmTime: Int) {
        self.size = size
        self.satPerByte = satPerByte
        self.confirmTime = confirmTime
    }
    
}
