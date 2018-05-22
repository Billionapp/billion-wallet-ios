//
//  UILabel+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension UILabel {

    func adopt() {
        
        guard let device = UIDevice.current.model else {
            return
        }
        
        switch device {
        case .iPhone4:
            font = UIFont(name: font.fontName, size: font.lineHeight - 5)
        default:
            break
        }

    }

}
