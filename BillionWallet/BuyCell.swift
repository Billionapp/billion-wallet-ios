//
//  BuyCell.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BuyCell: UITableViewCell {
    
    typealias LocalizedString = Strings.Buy
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var buyTitleLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var sellTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.layer.cornerRadius = Layout.model.cornerRadius
        iconImageView.layer.masksToBounds = true
        buyTitleLabel.text = LocalizedString.buyTitle
        sellTitleLabel.text = LocalizedString.sellTitle
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = Theme.Color.selected
        selectedBackgroundView = backgroundView
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        buyLabel.text = "-"
        sellLabel.text = "-"
    }
    
    func configure(with model: ExchangeModel) {
        if let imageData = Data(base64Encoded: model.exchange.icon_base64, options: .ignoreUnknownCharacters) {
            iconImageView.image = UIImage(data: imageData)
        }
        titleLabel.text = model.exchange.title
        buyTitleLabel.text = model.state.buyLabel
        sellTitleLabel.text = model.state.sellLabel
        
        let currency = model.state.currency
        if let method = model.method {
            if let info = model.rates?.buyRateForMethod(method) {
                buyLabel.text = stringCurrencyRounded(from: info.rate.btc, localeIso: currency)
            }

            if let info = model.rates?.sellRateForMethod(method) {
                sellLabel.text = stringCurrencyRounded(from: info.rate.btc, localeIso: currency)
            }
        } else {
            if let info = model.rates?.bestBuyForCurrency(iso: currency) {
                buyLabel.text = stringCurrencyRounded(from: info.rate.btc, localeIso: currency)
            }

            if let info = model.rates?.bestSellForCurrency(iso: currency) {
                sellLabel.text = stringCurrencyRounded(from: info.rate.btc, localeIso: currency)
            }
        }
      
        let buyHidden = buyTitleLabel.text == "-"
        buyLabel.isHidden = buyHidden
        buyTitleLabel.isHidden = buyHidden
        
        let sellHidden = sellTitleLabel.text == "-"
        sellLabel.isHidden = sellHidden
        sellTitleLabel.isHidden = sellHidden
    }
    
    
}

