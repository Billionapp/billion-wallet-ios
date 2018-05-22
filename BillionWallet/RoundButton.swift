//
//  RoundButton.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

open class RoundButton: UIButton {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup(with: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup(with: frame)
    }
    
    func setup(with bFrame: CGRect) {
        layer.cornerRadius = bFrame.width / 2
        layer.masksToBounds = true
        let normalImage = UIImage(color: UIColor.white.withAlphaComponent(0.3))
        let selectedImage = UIImage(color: UIColor.white.withAlphaComponent(0.6))
        setBackgroundImage(normalImage, for: .normal)
        setBackgroundImage(selectedImage, for: .highlighted)
    }
}
