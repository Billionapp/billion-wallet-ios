//
//  RadialGradientView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

@IBDesignable
class RadialGradientView: UIView {
    
    @IBInspectable var InsideColor: UIColor = UIColor.black.withAlphaComponent(0.4)
    @IBInspectable var InsideColor2: UIColor = UIColor.black.withAlphaComponent(0.5)
    @IBInspectable var OutsideColor: UIColor = UIColor.black.withAlphaComponent(0.6)
    
    @IBInspectable var innerDiameter: CGFloat = 218.0
    @IBInspectable var outerDiameter: CGFloat = 669.76
    
    override func draw(_ rect: CGRect) {
        let colors = [InsideColor.cgColor, InsideColor2.cgColor, OutsideColor.cgColor] as CFArray
        let endRadius = outerDiameter/2
        let startRadius = innerDiameter/2
        let center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
        let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: [0, 0.55, 1.0])
        UIGraphicsGetCurrentContext()!.drawRadialGradient(gradient!, startCenter: center, startRadius: startRadius, endCenter: center, endRadius: endRadius, options: CGGradientDrawingOptions.drawsAfterEndLocation)
    }
}
