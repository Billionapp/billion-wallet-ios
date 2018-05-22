//
//  String+NibNames.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01.12.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension String {
    
    func nibName() -> String {
        let height = UIScreen.main.bounds.size.height
        switch height {
        case 812:
            return "\(self)X"
        case 736:
            return "\(self)7+"
        case 667:
            return "\(self)7"
        case 568, 480:
            return "\(self)SE"
        default:
            return "\(self)7+"
        }
    }
    
    func nibNameForCell() -> String {
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        if width == 375 {
            return "\(self)7"
        } else if width == 414 {
            return "\(self)7+"
        } else if height == 568 {
            return "\(self)SE"
        } else {
            return "\(self)SE"
        }
    }
    
    func xibCellName() -> String {
        let nibName = self.nibName()
        if let _ = Bundle.main.path(forResource: nibName, ofType: "nib") {
            return nibName
        } else {
            return "\(self)7+"
        }
    }
}
