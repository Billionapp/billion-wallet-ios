//
//  AddContactTypeVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol AddContactTypeVMDelegate: class {
    func contactAddressDidScan(address: String)
}

class AddContactTypeVM {
    
    weak var delegate: AddContactTypeVMDelegate?
    let scanProvider: ScannerDataProvider
    fileprivate (set) var newContactScannedPC: String? {
        didSet {
            guard let string = newContactScannedPC else {
                return
            }
            
            if (try? PaymentCode(with: string)) != nil {
                scanProvider.scannedString = ""
                delegate?.contactAddressDidScan(address: string)
                return
            }
            
            if string.isValidBitcoinAddress {
                delegate?.contactAddressDidScan(address: string)
            } else {
                if string.contains(":") {
                    if let address = string.components(separatedBy:":").last {
                        scanProvider.scannedString = ""
                        delegate?.contactAddressDidScan(address: address)
                        return
                    }
                }
                let popup = PopupView.init(type: .cancel, labelString: NSLocalizedString("Address is invalid", comment:""))
                UIApplication.shared.keyWindow?.addSubview(popup)
            }
        }
    }
    
    init(scanProvider: ScannerDataProvider) {
        self.scanProvider = scanProvider
    }
    
    func setFromProvider () {
        newContactScannedPC = scanProvider.scannedString
    }
    
    deinit {
        scanProvider.scannedString = ""
    }
    
}
