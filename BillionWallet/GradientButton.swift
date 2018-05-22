//
//  GradientButton.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import CoreImage

class GradientButton: UIButton {
    
    var gradientLayer: CALayer?
    var gradientLayerSelected: CALayer?
    
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
        self.gradientLayerSelected?.frame = self.bounds
    }
    
    fileprivate func setup() {

        layer.standardCornerRadius()
        backgroundColor = .clear
        
        gradientLayer = applyGradient([Color.buttonTop, Color.buttonBottom], locations: [0, 1])
        self.setBackgroundImage(imageWithLayer(layer: gradientLayer!), for: .normal)
        gradientLayerSelected = applyGradient([Color.buttonTopSelected, Color.buttonBottomSelected], locations: [0, 1])
        self.setBackgroundImage(imageWithLayer(layer: gradientLayerSelected!), for: .highlighted)
        
        if let imageView = imageView {
            bringSubview(toFront: imageView)
        }
        titleLabel?.textAlignment = .center
    }
    
    func imageWithLayer(layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.screen)
        layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
