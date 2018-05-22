//
//  UIDevice+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum Device: CGFloat {
    case iPhone4 = 480
    case iPhone5 = 568
    case iPhone6 = 667
    case iPhone6Plus = 736
    case iPhoneX = 812
}

extension UIDevice {
    
    var model: Device? {
        return Device(rawValue: UIScreen.main.bounds.height)
    }
    
}
