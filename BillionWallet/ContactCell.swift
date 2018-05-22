//
//  ContactCell.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 23/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.standardCornerRadius()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .darkGray
        selectedBackgroundView = backgroundView
    }
    
}
