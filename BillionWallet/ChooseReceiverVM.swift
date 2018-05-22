//
//  ChooseReceiverVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol ChooseReceiverVMDelegate: class {
    func didStartContactFetch()
    func didFailedToFetch(_ errorMessage: String)
    func didChooseContact(_ contact: PaymentCodeContactProtocol)
    func didChoosePaymentRequest(_ paymentRequest: PaymentRequest)
    func didReceiveContacts()
    func scrollViewDidScroll(_ scrollView: UIScrollView)
}

class ChooseReceiverVM {
    
    typealias LocalizedStrings = Strings.ChooseReceiver
    
    var dataSource: ChooseReceiverDataSource!
    var contacts = [ContactProtocol]()

    private let contactsProvider: ContactsProvider
    private let apiProvider: API
    let tapticService: TapticService
    var qrResolver: QrResolver?
    
    lazy var pcHandler: QrResolver.Callback  = { [weak self] (qrString) in
        self?.setRecipientFrom(pc: qrString)
    }
    
    lazy var addressHandler: QrResolver.Callback  = { [weak self] (qrString) in
        self?.setRecipientFrom(address: qrString)
    }
    
    weak var delegate: ChooseReceiverVMDelegate?
    
    // MARK: - Lifecycle
    init(contactsProvider: ContactsProvider,
         apiProvider: API,
         tapticService: TapticService) {
        self.contactsProvider = contactsProvider
        self.apiProvider = apiProvider
        self.tapticService = tapticService
        self.dataSource = ChooseReceiverDataSource(viewModel: self)
        self.dataSource.delegate = self
    }
    
    func setResolver(_ resolver: QrResolver) {
        self.qrResolver = resolver
    }
    
    func getContacts() {
        contacts = contactsProvider.allContacts(isArchived: false)
        delegate?.didReceiveContacts()
    }
    
    private func selectContact(_ contact: PaymentCodeContactProtocol) {
        delegate?.didChooseContact(contact)
    }
    
    private func setRecipientFrom(pc: String) {
        let contactsProvider = self.contactsProvider
        if let contact = contactsProvider.getFriendContact(paymentCode: pc) {
            delegate?.didChooseContact(contact)
            return
        }
        delegate?.didStartContactFetch()
        apiProvider.findUser(pc: pc) { (result) in
            switch result {
            case .success(let user):
                var contact = FriendContact.create(unique: user.pc)
                if let name = user.name {
                    contact.displayName = name
                }
                contact.avatarData = user.avatarData
                
                Logger.debug(String(format: "Saving friend contact with PC %@", pc))
                contactsProvider.save(contact)
                DispatchQueue.main.async {
                    self.delegate?.didChooseContact(contact)
                }
                return
            
            case .failure(_):
                var contact = contactsProvider.getOrCreatePaymentCodeContact(paymentCode: pc)
                contact.isArchived = false
                
                Logger.debug(String(format: "Saving payment code contact with PC %@", pc))
                contactsProvider.save(contact)
                DispatchQueue.main.async {
                    self.delegate?.didChooseContact(contact)
                }
                return
            }
        }
        return
    }
    
    private func setRecipientFrom(address: String) {
        if let paymentRequest = BRPaymentRequest(string: address),
            let foundAddress = paymentRequest.paymentAddress,
            foundAddress.isValidBitcoinAddress {
            
            var amount: UInt64 = 0
            if paymentRequest.amount > 0 {
                amount = paymentRequest.amount
            }
            let address = foundAddress
            let paymentRequest = PaymentRequest(address: address, amount: amount)
            delegate?.didChoosePaymentRequest(paymentRequest)
            return
        }
    }
    
    private func setRecipient(from string: String?) {
        guard let string = string else {
            return
        }

        if let _ = try? PaymentCode(with: string) {
            let contactsProvider = self.contactsProvider
            if let contact = contactsProvider.getFriendContact(paymentCode: string) {
                delegate?.didChooseContact(contact)
                return
            }
            delegate?.didStartContactFetch()
            apiProvider.findUser(pc: string) { (result) in
                switch result {
                case .success(let user):
                    var contact = FriendContact.create(unique: user.pc)
                    if let name = user.name {
                        contact.displayName = name
                    }
                    contact.avatarData = user.avatarData

                    Logger.debug(String(format: "Saving friend contact with PC %@", string))
                    contactsProvider.save(contact)
                    DispatchQueue.main.async {
                        self.delegate?.didChooseContact(contact)
                    }
                    return
                    
                case .failure(_):
                    var contact = contactsProvider.getOrCreatePaymentCodeContact(paymentCode: string)
                    contact.isArchived = false

                    Logger.debug(String(format: "Saving payment code contact with PC %@", string))
                    contactsProvider.save(contact)
                    DispatchQueue.main.async {
                        self.delegate?.didChooseContact(contact)
                    }
                    return
                }
            }
            return
        }

        if let paymentRequest = BRPaymentRequest(string: string),
            let foundAddress = paymentRequest.paymentAddress,
            foundAddress.isValidBitcoinAddress {

            var amount: UInt64 = 0
            if paymentRequest.amount > 0 {
                amount = paymentRequest.amount
            }
            let address = foundAddress
            let paymentRequest = PaymentRequest(address: address, amount: amount)
            delegate?.didChoosePaymentRequest(paymentRequest)
            return
        }

        showErrorPopupWithString(title: String(format: LocalizedStrings.cannotProcessFormat, string))
    }
    
    func showErrorPopupWithString(title: String) {
        let popup = PopupView(type: .cancel, labelString: title)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    func pasteFromClipboard() {
        guard let recipientString = UIPasteboard.general.string else {
            showErrorPopupWithString(title: LocalizedStrings.noStringInClipboard)
            return
        }
        do {
            let callback = try qrResolver?.resolveQr(recipientString)
            callback?(recipientString)
        } catch let error {
            showErrorPopupWithString(title: error.localizedDescription)
        }
    }
    
    fileprivate func selectContactFromContactView(contact: ContactProtocol) {
        if let pcContact = contact as? PaymentCodeContactProtocol {
            selectContact(pcContact)
        } else {
            setRecipient(from: contact.uniqueValue)
        }
    }
}

// MARK: - ChooseReceiverDataSourceDelegate
extension ChooseReceiverVM: ChooseReceiverDataSourceDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }
    
    func didSelect(at index: Int) {
        let contact = contacts[index]
        selectContactFromContactView(contact: contact)
    }
}

// MARK: - ContactsOutputDelegate
extension ChooseReceiverVM: ContactsOutputDelegate {
    func didSelectContact(_ contact: ContactProtocol) {
        selectContactFromContactView(contact: contact)
    }
}
