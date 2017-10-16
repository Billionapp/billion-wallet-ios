//
//  BalanceDeltaView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BalanceDeltaView: LoadableFromXibView {
    
    typealias Model = (balance: String, delta: String, plus: Bool)

    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var deltaLabel: UILabel!

    override func xibSetup() {
        super.xibSetup()
        view.backgroundColor = .clear
        deltaLabel.layer.cornerRadius = 6
        deltaLabel.layer.masksToBounds = true
    }
}

// MARK: - Configurable

extension BalanceDeltaView: Configurable {
    
    func configure(with model: BalanceDeltaView.Model) {
        balanceLabel.text = model.balance
        deltaLabel.text = model.delta
        deltaLabel.backgroundColor = model.plus ? Theme.Color.green : Theme.Color.red
    }
    
}
