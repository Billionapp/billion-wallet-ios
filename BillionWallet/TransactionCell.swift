//
//  TransactionCell.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol TransactionCellDelegate: class {
    func bubbleButtonPressed(_ sender: TransactionCell)
}

class TransactionCell: UITableViewCell {
    
    weak var delegate: TransactionCellDelegate?

    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var bubbleButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainCurrencyLabel: UILabel!
    @IBOutlet weak var btcLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contactImageView.layer.cornerRadius = 20
        contactImageView.clipsToBounds = true
        
    }
    
    @IBAction func bubbleButtonPressed(_ sender: UIButton) {
        delegate?.bubbleButtonPressed(self)
    }
}

// MARK: - Configure

extension TransactionCell {
    
    func configure(with transaction: Transaction) {
        timeLabel.text = transaction.timestamp?.humanReadable
        bubbleButton.alpha = transaction.isNotificationTx ? 0.5 : 1.0
    
        if transaction.sent > 0 {
            titleLabel.text = transaction.status.title ?? NSLocalizedString("Sent", comment: "")
            btcLabel.text = transaction.bitsAmount
            mainCurrencyLabel.text = "- " + transaction.localCurrencyAmount
            bubbleButton.setImage(#imageLiteral(resourceName: "redRightBubble"), for: .normal)
        } else {
            titleLabel.text = transaction.status.title ?? NSLocalizedString("Received", comment: "")
            btcLabel.text = transaction.bitsAmount
            mainCurrencyLabel.text = "+ " + transaction.localCurrencyAmount
            bubbleButton.setImage(#imageLiteral(resourceName: "greenLeftBubble"), for: .normal)
        }
    }
}
