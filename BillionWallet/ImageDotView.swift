//
//  ImageDotView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ImageDotFactory: DotFactory {
    func createDot(size: CGFloat) -> DotView {
        return ImageDotView(size: size)
    }
}

class ImageDotView: DotView {
    private var circleImage: UIImageView!
    
    override var isSet: Bool {
        didSet {
            circleImage?.isHighlighted = isSet
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
        circleImage = UIImageView(frame: self.bounds)
        circleImage.image = #imageLiteral(resourceName: "ClearDot")
        circleImage.highlightedImage = #imageLiteral(resourceName: "FilledDot")
        self.addSubview(circleImage)
    }
}
