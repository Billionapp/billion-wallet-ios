//
//  BuyPickerVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol BuyPickerOutputDelegate: class {
    func didSelectPaymentMethod(_ method: PaymentMethod)
}

protocol BuyPickerVMDelegate: class {
    func selectMethodAtIndex(_ index: Int)
}

class BuyPickerVM {

    let selectedMethod: PaymentMethod?
    let paymentMethods: [PaymentMethod]
    weak var delegate: BuyPickerVMDelegate?
    weak var output: BuyPickerOutputDelegate?

    init(method: PaymentMethod?, methods: [String]?, paymentMethodsFactory: PaymentMethodFactory, output: BuyPickerOutputDelegate?) {
        self.output = output
        self.selectedMethod = method
        
        let all = paymentMethodsFactory.getPaymentMethods()
        if let methods = methods {
            self.paymentMethods = all.filter { methods.contains($0.symbol) }
        } else {
            self.paymentMethods = all
        }
    }
    
    func selectRow(at index: Int) {
        output?.didSelectPaymentMethod(paymentMethods[index])
    }
    
    func selectMethodIfNeeded() {
        guard let selected = selectedMethod, let index = paymentMethods.index(of: selected) else {
            return
        }
        delegate?.selectMethodAtIndex(index)
    }

}
