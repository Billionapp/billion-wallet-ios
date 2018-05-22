//
//  ShopCell.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ShopCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Layout.model.cornerRadius
        layer.masksToBounds = true
    }
    
    func configure(with shop: Shop) {
        imageView.image = UIImage(named: shop.image)
    }

}
