//
//  LoaderView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class LoaderView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(size: CGSize) {
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let back = drawLoaderBack(bounds: size)
        let backView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        backView.image = back
        self.addSubview(backView)
        
        for i in 0...4 {
            let image = drawSliceImage(bounds: size, number: i)
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            imageView.image = image
            imageView.rotateView(duration: 2.75+drand48()*2, clockwise: i%2==0)
            self.addSubview(imageView)
        }
    }
    
    func stopAnimation() {
        self.removeFromSuperview()
    }
    
    fileprivate func drawSliceImage(bounds:CGSize, number: Int) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(bounds, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let sliceWidth: CGFloat = bounds.height/15
        let interim = sliceWidth/3
        let radius = bounds.height/2 - sliceWidth/2 - ((sliceWidth+interim)*CGFloat(number))
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        
        let arc1Path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(arc4random_uniform(1)+5), clockwise: true)
        
        context.setLineWidth(sliceWidth)
        context.setLineCap(.round)
        context.addPath(arc1Path.cgPath)
        let alpha = CGFloat(number+1)/5
        let bgColor = UIColor.white.withAlphaComponent(alpha).cgColor
        context.setStrokeColor(bgColor)
        context.strokePath()
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        UIGraphicsEndImageContext()
        
        return UIImage(cgImage: img)
    }
    
    func drawLoaderBack(bounds: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        
        let sliceWidth: CGFloat = bounds.height/15
        let interim = sliceWidth/3
        var radius = bounds.height/2 - sliceWidth/2
        
        var circleRect = CGRect(x: bounds.width/2 - radius, y: bounds.height/2 - radius, width: 2*radius, height: 2*radius)
        var circlePath = UIBezierPath(ovalIn: circleRect)
        var alpha:CGFloat = 0.05
        
        context.setLineWidth(sliceWidth)
        
        for i in 0...4 {
            
            if i != 0 {
                radius = bounds.height/2 - sliceWidth/2 - ((sliceWidth+interim)*CGFloat(i))
                circleRect = CGRect(x: bounds.width/2 - radius, y: bounds.height/2 - radius, width: 2*radius, height: 2*radius)
                circlePath = UIBezierPath(ovalIn: circleRect)
                alpha = 0.05+(0.05*CGFloat(i))
            }
            
            context.addPath(circlePath.cgPath)
            let color = UIColor.white.withAlphaComponent(alpha)
            context.setStrokeColor(color.cgColor)
            context.strokePath()
        }
        
        let img = UIGraphicsGetImageFromCurrentImageContext()!.cgImage!
        UIGraphicsEndImageContext()
        
        return UIImage(cgImage: img)
    }
}

extension UIView {
    func rotateView(duration: CFTimeInterval, clockwise: Bool) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        let value = clockwise ? CGFloat(Double.pi * 2) : CGFloat(-Double.pi * 2)
        rotateAnimation.toValue = value
        rotateAnimation.isRemovedOnCompletion = true
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
