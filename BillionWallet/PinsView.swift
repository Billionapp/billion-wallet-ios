//
//  PinsView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class PinsView: UIView {
    @IBInspectable private var dotSize: CGFloat = 13
    @IBInspectable private var interDotSpace: CGFloat = 25
    
    private var dots: [DotView] = []
    
    var dotFactory: DotFactory = ImageDotFactory()
    
    var maxDots: Int = 6 {
        didSet {
            setMaxDots(maxDots)
        }
    }
    
    var filledDots: Int = 0 {
        didSet {
            setFilledDots(filledDots)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setMaxDots(maxDots)
        setFilledDots(filledDots)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setMaxDots(maxDots)
        setFilledDots(filledDots)
    }
    
    override func layoutSubviews() {
        updateLayout()
    }
    
    private func updateLayout() {
        let n = dots.count
        guard n > 0 else {
            return
        }
        let clusterCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        let totalWidth: CGFloat = CGFloat(n)*dotSize + CGFloat(n-1)*interDotSpace
        for (i, dot) in dots.enumerated() {
            let dx = -0.5*totalWidth + CGFloat(i)*(dotSize + interDotSpace)
            let dy = -0.5*dotSize
            dot.frame.origin = CGPoint(x: clusterCenter.x + dx,
                                       y: clusterCenter.y + dy)
        }
    }
    
    private func setMaxDots(_ count: Int) {
        for dot in dots {
            dot.removeFromSuperview()
        }
        dots = []
        for i in 0..<count {
            let newDot = dotFactory.createDot(size: dotSize)
            newDot.isSet = i < filledDots
            dots.append(newDot)
            self.addSubview(newDot)
        }
        updateLayout()
    }
    
    private func setFilledDots(_ count: Int) {
        if count > maxDots {
            filledDots = maxDots
            return
        }
        for (i, dot) in dots.enumerated() {
            dot.isSet = i < count
        }
    }
}
