//
//  ImportKeyPublishView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ImportKeyPublishView: UIView {

    @IBOutlet private weak var addressLabel: UILabel?
    @IBOutlet weak var localCurrencyAmountLabel: UILabel!
    @IBOutlet weak var amountBitsLabel: UILabel!
    
    private weak var viewModel: ImportKeyVM?
    
    init(address: String, localCurrencyAmount: String, amount: String, viewModel: ImportKeyVM) {
        super.init(frame: UIScreen.main.bounds)
        fromNib()
        addBlur()
        addressLabel?.text = address
        localCurrencyAmountLabel.text = "+ \(localCurrencyAmount)"
        amountBitsLabel.text = amount
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func startAction() {
        viewModel?.start()
        close()
    }
    
    @IBAction func closeAction() {
        close()
    }
    
    func close() {
        self.removeFromSuperview()
    }

}
