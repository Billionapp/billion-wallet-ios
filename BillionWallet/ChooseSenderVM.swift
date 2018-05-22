//
//  ChooseSenderVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol ChooseSenderVMDelegate: class {
    func didReceiveContacts()
    func didSelectContact(_ contact: ContactProtocol)
    func didReceiveQRImage(_ image: UIImage?)
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class ChooseSenderVM {
    
    private weak var contactsProvider: ContactsProvider!
    private weak var walletProvider: WalletProvider!
    weak var delegate: ChooseSenderVMDelegate?
    let tapticService: TapticService
    var dataSource: ChooseSenderDataSource!
    var contacts = [ContactProtocol]()

    init(contactsProvider: ContactsProvider,
         walletProvider: WalletProvider,
        tapticService: TapticService) {
        
        self.contactsProvider = contactsProvider
        self.walletProvider = walletProvider
        self.tapticService = tapticService
        self.dataSource = ChooseSenderDataSource(viewModel: self)
        self.dataSource.delegate = self
    }
    
    func getContacts() {
        contacts = contactsProvider.allContacts(isArchived: false)
        delegate?.didReceiveContacts()
    }
    
    func getQRImage() {
        guard let wallet = try? walletProvider.getWallet() else {
            Logger.warn("No wallet")
            return
        }
        let address = wallet.receiveAddress
        let qrImage = createQRFromString(address, size: CGSize(width: 280, height: 280), inverseColor: true)
        delegate?.didReceiveQRImage(qrImage)
    }

}

// MARK: - ContactsOutputDelegate
extension ChooseSenderVM: ContactsOutputDelegate {
    func didSelectContact(_ contact: ContactProtocol) {
        delegate?.didSelectContact(contact)
    }
}

// MARK: - ChooseSenderDataSourceeDelegate
extension ChooseSenderVM: ChooseSenderDataSourceDelegate {
    func didSelect(at index: Int) {
        delegate?.didSelectContact(contacts[index])
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
}
