//
//  SettingsCommissionVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol SettingsCommissionVMDelegate: class {
    func commissionDidChange(_ commission: FeeSize)
}

class SettingsCommissionVM {
    
    let defaultsProvider: Defaults
    
    weak var delegate: SettingsCommissionVMDelegate? {
        didSet {
            delegate?.commissionDidChange(selectedCommission)
        }
    }
    
    var selectedCommission: FeeSize! {
        didSet {
            delegate?.commissionDidChange(selectedCommission)
        }
    }
    
    init(defaultsProvider: Defaults) {
        self.defaultsProvider = defaultsProvider
        self.selectedCommission = defaultsProvider.commission
    }

    func save() {
        defaultsProvider.commission = selectedCommission
    }
    
}
