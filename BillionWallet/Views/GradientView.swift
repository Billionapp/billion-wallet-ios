//
//  GradientView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class GradientView: UIView {

    var gradientLayer: CALayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.gradientLayer?.frame = self.bounds
    }
    
    fileprivate func setup() {
        layer.standardCornerRadius()
        backgroundColor = .clear
        let colorLeft = Color.buttonTop
        let colorRight = Color.buttonBottom
        gradientLayer = applyGradient([colorLeft, colorRight], locations: [0, 1])
        layer.insertSublayer(gradientLayer!, at: 0)
    }

}
