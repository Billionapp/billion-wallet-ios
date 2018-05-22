//
//  BuyPickerViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BuyPickerViewController: BaseViewController<BuyPickerVM>, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var pickerView: UIPickerView!
    
    weak var router: MainRouter?

    override func configure(viewModel: BuyPickerVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.selectMethodIfNeeded()
    }
    
    // MARK: - Private methods
    
    // MARK: - Actions
    
    @IBAction func okPressed(_ sender: UIButton) {
        let index = pickerView.selectedRow(inComponent: 0)
        viewModel.selectRow(at: index)
        navigationController?.pop()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.paymentMethods.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let method = viewModel.paymentMethods[row]
        let title = "\(method.name)"
        let attributedString = NSAttributedString(string: title, attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        return attributedString
    }

}

extension BuyPickerViewController: BuyPickerVMDelegate {
    
    func selectMethodAtIndex(_ index: Int) {
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }

}
