//
//  CircleView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    enum Style {
        case light
        case dark
    }
    
    public var style: Style = .light {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height)/2.0
    }
    
    fileprivate func updateAppearance() {
        switch style {
        case .light:
            backgroundColor = .white
        case .dark:
            backgroundColor = .black
        }
    }
}
