//
//  NumberKeyButton.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class NumberKeyButton: UIButton {
    
    let highlightedColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.6)
    let normalColor = UIColor(red: 147/255, green: 147/255, blue: 147/255, alpha: 0.6)

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        titleLabel?.font = UIFont.systemFont(ofSize: 28)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        backgroundColor = normalColor
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightedColor : normalColor
        }
    }
}
