//
//  SetupAvatarCell.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SetupAvatarCell: UICollectionViewCell {
    
    @IBOutlet weak var avatar: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.layer.cornerRadius = 10
        avatar.layer.masksToBounds = true
    }

}
