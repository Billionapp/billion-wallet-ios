//
//  VerticalProgressIndicator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class VerticalProgressIndicator {
    private var progressLayer: CAShapeLayer
    private var progressPath: UIBezierPath
    
    init() {
        progressLayer = CAShapeLayer()
        progressPath = UIBezierPath()
    }
    
    func setup(on rootView: UIView) {
        progressLayer.frame = rootView.bounds
        
        // Line path from center bot to top
        let centerTop = CGPoint(x: rootView.bounds.midX, y: 0)
        let centerBottom = CGPoint(x: rootView.bounds.midX, y: rootView.bounds.maxY)
        progressPath = UIBezierPath()
        progressPath.move(to: centerBottom)
        progressPath.addLine(to: centerTop)
        progressPath.addLine(to: centerBottom)
        progressPath.close()
        
        // Shape layer in shape of path
        progressLayer.lineCap = kCALineCapButt
        progressLayer.strokeColor = UIColor.black.cgColor
        progressLayer.strokeStart = 0.5
        progressLayer.strokeEnd = 0.5
        progressLayer.lineWidth = rootView.frame.width
        progressLayer.path = progressPath.cgPath
        
        rootView.layer.mask = progressLayer
    }
    
    func setProgress(_ progress: Float) {
        // 0.5 to 1.0 stroke progress = 0 to 1 total progress
        // because it has a closed path
        progressLayer.strokeEnd = CGFloat(progress)/2 + 0.5
    }
}
