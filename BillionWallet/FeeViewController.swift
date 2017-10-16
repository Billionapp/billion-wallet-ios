//
//  FeeViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

class FeeViewController: BaseViewController<FeeVM> {
    
    weak var mainRouter: MainRouter?
    fileprivate var titledView: TitledView!

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var timeConfirmationLabel: UILabel!
    @IBOutlet weak var commonAmountLabel: UILabel!
    @IBOutlet weak var feeSizeLabel: UILabel!
    @IBOutlet weak var localCurrencyLabel: UILabel!
    
    override func configure(viewModel: FeeVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        setupThumb()
        viewModel.getTransactionFee()
        titledView = TitledView()
        titledView.title = "Bitcoin network fee"
        titledView.subtitle = "Increase the commission to expedite the receipt of the transaction"
        titledView.closePressed = {
            self.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        viewModel.sendTransaction()
        navigationController?.pop()
    }
    
    @IBAction func skiderValueDidChanged(_ sender: UISlider) {
        viewModel.valueDidChanged(value: sender.value)
    }
    
}

//MARK: - FeeVMDelegate
extension FeeViewController: FeeVMDelegate {
    func didChange(to: TransactionFee) {
        let fee = to.estematedFee ?? 0
        
        if let estematedMinutes = to.estematedMinutes, estematedMinutes != 0 {
            timeConfirmationLabel.text = "≈\(String(estematedMinutes)) min"
        } else {
            timeConfirmationLabel.text = "≈10 min"
        }
        
        feeSizeLabel.text = "\(String(fee / 100)) ƀ"
        localCurrencyLabel.text = viewModel.localCurrencyString(for: Int64(fee))
        
        guard let amount = viewModel.amount else {
            return
        }
        
        let fullAmount = (fee + amount)/100
        commonAmountLabel.text = "\(fullAmount) ƀ"
    }
    
    func didFeeRequestFailed() {
        navigationController?.pop()
    }
}

//MARK: - Setup
extension FeeViewController {
    func setupThumb() {
        slider?.setThumbImage(UIImage(named: "FeeThumb"), for: .normal)
    }
}


