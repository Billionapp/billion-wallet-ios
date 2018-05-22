//
//  UILabel+Dynamic.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension UILabel {
    func bind(to dynamic: Dynamic<String>) {
        dynamic.bind { self.text = $0 }
    }
    
    func bindNow(to dynamic: Dynamic<String>) {
        dynamic.bindAndFire { self.text = $0 }
    }
}
