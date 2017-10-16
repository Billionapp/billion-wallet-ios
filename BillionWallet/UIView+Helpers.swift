//
//  UIView+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension UIView {
    
    func center(in view: UIView) -> CGPoint {
        var point = self.center
        
        var sv = self.superview
        while sv != view && sv != nil {
            point.x += sv!.frame.origin.x
            point.y += sv!.frame.origin.y
            sv = sv!.superview
        }
        return point
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
}

extension UIImageView{
    func addBlackGradientLayer(frame: CGRect = CGRect(x: 0, y: UIScreen.main.bounds.size.width - 120, width: UIScreen.main.bounds.size.width, height: 120)) {
        let gradient = CAGradientLayer()
        gradient.frame = frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 0.5]
        self.layer.addSublayer(gradient)
    }
}
