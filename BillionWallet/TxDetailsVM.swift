//
//  TxDetailsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol TxDetailsVMDelegate: class {
    func addressTitleDidSet(title: String?)
    func avatarDidSet(image: UIImage)
}

class TxDetailsVM {
    
    let transaction: Transaction
    weak var delegate: TxDetailsVMDelegate?
    weak var walletProvider: WalletProvider?
    var address: String? {
        didSet {
            delegate?.addressTitleDidSet(title: address)
        }
    }
    
    init(transaction: Transaction, walletProvider: WalletProvider) {
        self.transaction = transaction
        self.walletProvider = walletProvider
    }
    
    func setAddressTitleAndAvatar() {
        if let contact = transaction.contact {
            delegate?.addressTitleDidSet(title: contact.uniqueValue)
            delegate?.avatarDidSet(image: contact.avatarImage)
        } else {
            // TODO: Refactor
            if transaction.isReceived {
                address = myAddress()
            } else {
                address = partnerAddress()
            }
        }
    }
    
    func myAddress() -> String? {
        let outputsAddresses = transaction.brTransaction.outputAddresses.filter { $0 is NSString }.map { $0 as! String}
        let arrayOfAddress = outputsAddresses.filter { (walletProvider?.manager.wallet?.containsAddress($0))! }
        return arrayOfAddress.first
    }
    
    func partnerAddress() -> String? {
        if transaction.isReceived {
            return transaction.brTransaction.inputAddresses.first as? String
        } else {
            let outputsAddresses = transaction.brTransaction.outputAddresses.flatMap { $0 as? String}
            let addressSet: Set<String> = Set(outputsAddresses)
            let changeSet = walletProvider?.manager.wallet?.allChangeAddresses as! Set<String>
            let intersection = addressSet.subtracting(changeSet)
            return intersection.first
        }
    }
}
