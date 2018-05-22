//
//  DotView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol DotFactory {
    func createDot(size: CGFloat) -> DotView
}

class DotView: UIView {
    var isSet: Bool = false
}
