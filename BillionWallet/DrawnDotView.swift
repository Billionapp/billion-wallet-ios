//
//  DrawnDotView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class DrawnDotFactory: DotFactory {
    func createDot(size: CGFloat) -> DotView {
        return DrawnDotView(size: size)
    }
}

class DrawnDotView: DotView {
    private var circleLayer: CAShapeLayer!
    
    private let borderColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let setColor: CGColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    private let unsetColor: CGColor = UIColor.clear.cgColor
    
    override var isSet: Bool {
        didSet {
            circleLayer?.fillColor = isSet ? setColor : unsetColor
        }
    }
    
    init(size: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        configureImage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureImage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureImage()
    }
    
    private func configureImage() {
        self.backgroundColor = .clear
        
        let circlePath = UIBezierPath(ovalIn: self.bounds.insetBy(dx: 1, dy: 1))
        circleLayer = CAShapeLayer()
        circleLayer.frame = self.bounds
        circleLayer.path = circlePath.cgPath
        
        circleLayer.strokeColor = borderColor
        circleLayer.lineWidth = 1.5
        circleLayer.fillColor = unsetColor
        self.layer.addSublayer(circleLayer)
    }
}
