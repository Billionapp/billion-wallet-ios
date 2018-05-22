//
//  UserAvatarSmallImageView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class UserAvatarSmallImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override init(image: UIImage?) {
        super.init(image: image)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        self.backgroundColor = UIColor(red: 58/255, green: 63/255, blue: 78/255, alpha: 1.0)
        self.contentMode = .scaleAspectFill
        self.layer.standardCornerRadius()
    }
}
