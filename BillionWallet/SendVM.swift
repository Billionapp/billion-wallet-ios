//
//  SendVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum RecipientType {
    case none
    case address
    case existingPaymentCode
    case newPaymentCode
}

protocol SendVMDelegate: class {
    func amountDidChange(amount: UInt64)
    func recipientDidChange(newRecipient: String)
    func didReceiveContact(contact: ContactProtocol)
    func didChooseCustomFee()
    func showPasscodeView()
    func didSendTransaction(text: String)
    func didFailSendTransaction(text: String)
    func setTextFieldFromAmount(amount: UInt64)
}

class SendVM: NSObject, UITextFieldDelegate {
     fileprivate (set) var recipientString: String? {
        didSet {
            guard let string = recipientString else {
                address = nil
                return
            }
            
            if let _ = try? PaymentCode(with: string) {
                stringForQr = string
                delegate?.recipientDidChange(newRecipient: string)
                contact = contactsProvider.getOrCreatePaymentCodeContact(paymentCode: recipientString!)
                address = contact?.addressToSend()
                return
            }
            
            if let paymentRequest = BRPaymentRequest(string: string),
                let foundAddress = paymentRequest.paymentAddress,
                paymentRequest.paymentAddress.isValidBitcoinAddress {
                if paymentRequest.amount > 0 {
                    self.amount = paymentRequest.amount
                    delegate?.setTextFieldFromAmount(amount: amount)
                }
                address = foundAddress
                delegate?.recipientDidChange(newRecipient: foundAddress)
                return
            }
            
            showErrorPopupWithString(title: String(format: NSLocalizedString("Cannot process message: \"%@\"", comment:""), string))
        }
    }
    
    var address: String?

    var isNotificationTxNeededToSend: Bool {
        return contact?.isNotificationTxNeededToSend ?? false
    }
    
    var amount: UInt64 {
        didSet {
            delegate?.amountDidChange(amount: amount)
        }
    }
    var contact: ContactProtocol? {
        didSet {
            guard let contact = contact else { return }
            delegate?.didReceiveContact(contact: contact)
        }
    }
    weak var delegate: SendVMDelegate? {
        didSet {
            delegate?.amountDidChange(amount: amount)
            if let addressExist = address {
                delegate?.recipientDidChange(newRecipient: addressExist)
            }
        }
    }
    
    let scanProvider: ScannerDataProvider
    let contactsProvider: ContactsProvider
    let notificationTransactionProvider: NotificationTransactionProvider
    var stringForQr: String?
    var addressFromScanner: String?
    weak var walletProvider: WalletProvider?
    weak var defaultsProvider: Defaults?
    weak var icloudProvider: ICloud?
    weak var feeProvider: FeeProvider?
    weak var api: API?
    weak var ratesProvider: RatesProvider!
    var tx : BRTransaction? = nil
    var txComment: String = ""
    var isCustomFee: Bool {
        return defaultsProvider?.commission == FeeSize.custom
    }
    
    // MARK: - Lifecycle
    init(walletProvider: WalletProvider, scanProvider: ScannerDataProvider, defaultsProvider: Defaults, contactsProvider: ContactsProvider, notificationTransactionProvider: NotificationTransactionProvider,  icloudProvider: ICloud, api: API, feeProvider: FeeProvider, rateProvider: RatesProvider) {
        self.walletProvider = walletProvider
        self.amount = 0
        self.scanProvider = scanProvider
        self.defaultsProvider = defaultsProvider
        self.icloudProvider = icloudProvider
        self.contactsProvider = contactsProvider
        self.notificationTransactionProvider = notificationTransactionProvider
        self.feeProvider = feeProvider
        self.api = api
        self.ratesProvider = rateProvider
    }
    
    // MARK: Text field delegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if range.length == 0 { //adding character
            if !CharacterSet.decimalDigits.contains(string.unicodeScalars.first!) && !(string.hasPrefix(Locale.current.decimalSeparator!)){
                return false
            } else {
                let newString = "\(textField.text ?? "")\(string)"
                let value = Decimal(string: newString) ?? Decimal(0)
                let currency = CurrencyFactory.currencyWithCode(walletProvider!.manager.localCurrencyCode ?? "USD")
                let converter = FiatConverter(currency: currency!, ratesSource: ratesProvider)
                amount = converter.convertToBtc(fiatValue: value)
                textField.text = newString
                return false
            }
        } else { // erase last character
            if range.location == 0  { // all characters was erased
                stringForQr = address
                amount = 0
            } else {
                let text = textField.text ?? ""
                let newString = String(text.characters.dropLast())
                let value = Decimal(string: newString) ?? Decimal(0)
                let currency = CurrencyFactory.currencyWithCode(walletProvider!.manager.localCurrencyCode ?? "USD")
                let converter = FiatConverter(currency: currency!, ratesSource: ratesProvider)
                amount = converter.convertToBtc(fiatValue: value)
            }
            
            return true
        }
    }
    
    // MARK: OTHERS
    func qrFromString() -> UIImage? {
        if let string = stringForQr {
            return createQRFromString(string, size: CGSize(width: 280, height: 280))
        }
        return nil
    }
    
    func pasteFromClipboard() {
        recipientString = UIPasteboard.general.string
    }
    
    func setFromProvider () {
        recipientString = scanProvider.scannedString
    }
    
    
    var txFee: FeeSize {
        return defaultsProvider?.commission ?? .normal
    }
    
    // MARK: CONFIRM REQUEST
    func confirmProtocolRequest(customFee: Fee? = nil, withStringAddress address: String, amount: Int64) {
        
        let req = BRPaymentRequest(string: address)
        //var fee: UInt64 = 0
        guard let request = req else { return }
        
        let fee = customFee ?? feeProvider?.getFee(size: (defaultsProvider?.commission)!)
        let satoshiPerByte = fee?.satPerByte ?? 0
        
        if let request = request.protocolRequest.details.outputScripts.first {
            tx = walletProvider?.manager.wallet?.transaction(forAmounts: [amount], toOutputScripts: [request], andCustomFee: UInt64(satoshiPerByte))
            
            if let transaction = tx {
                let amountFromTx = ((walletProvider?.manager.wallet?.amountSent(by: transaction))! - (walletProvider?.manager.wallet?.amountReceived(from: transaction))!)
                //fee = (walletProvider?.manager.wallet?.fee(for: transaction))!
                
                let signResult = self.confirmTransaction(tx: tx!, withPrompt: "", forAmount: amountFromTx)
                
                Logger.info("Sign result: \(signResult)")
            } else {
                showErrorPopupWithString(title: "Insufficient funds")
            }
        }
    }
    
    func confirmTransaction(tx: BRTransaction, withPrompt prompt : NSString, forAmount amount: UInt64) -> Bool {
        
        let didAuth = walletProvider?.manager.didAuthenticate
        
        if !didAuth! {walletProvider?.manager.didAuthenticate = false}
        
        if !(walletProvider?.manager.wallet?.sign(tx, withPrompt: prompt as String))! {
            return false
        }
        
        Logger.debug("Tx_id: \(Data(UInt256S(tx.txHash).data.reversed()).hex)")
        return true
    }
    
    func createTransaction(customFee: Fee? = nil) {

        if let addressUnwraped = address {
            confirmProtocolRequest(customFee: customFee, withStringAddress: addressUnwraped, amount: Int64(amount))
        }
    }
    
    func createNotificationTransaction(success: @escaping (String) -> (), failure: @escaping (String) -> Void) {
        let defaultHighFee = Fee(size: .normal, satPerByte: 300, confirmTime: 0)
        do {
            let notifTx = try notificationTransactionProvider.createNotificationTransaction(for: recipientString!, fee: defaultHighFee)
            notificationTransactionProvider.publish(notifTx, failure: {
                let errorStr = NSLocalizedString("Fail to send notification transaction", comment: "")
                failure(errorStr)
            }, completion: {
                success(UInt256S(notifTx.txHash).data.hex)
            })
        } catch {
            failure(error.localizedDescription)
        }
    }
    
    func publish(success: @escaping (String) -> Void, failure: @escaping (String) -> Void) {
        if let transaction = tx {
            walletProvider?.peerManager.publishTransaction(transaction, completion: { [weak self] (Error) in
                if (Error != nil) {
                    Logger.error("\(String(describing: Error?.localizedDescription))")
                    failure("\(String(describing: Error?.localizedDescription))")
                } else {
                    if let comment = self?.txComment {
                        if comment != "" {
                            let provider = TransactionNotesProvider(tx: transaction)
                            provider.setUserNote(with: comment)
                            
                            let icloudUserInfo = ICloudUserNote(userNote: comment, txHash: UInt256S(transaction.txHash).data.hex)
                            try? self?.icloudProvider?.backup(object: icloudUserInfo)
                        }
                    }
                    
                    self?.walletProvider?.manager.wallet?.register(transaction)
                    success("Success")
                }
            })
        }
    }
    
    func showErrorPopupWithString(title: String) {
        let popup = PopupView.init(type: .cancel, labelString: title)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    func sendAfterPasscode() {
        delegate?.showPasscodeView()
    }
    
    func send(customFee: Fee? = nil) {
        
        guard let address = address, let isContainAddress = walletProvider?.manager.wallet?.containsAddress(address), !isContainAddress else {
            delegate?.didFailSendTransaction(text: "You are trying to send funds to your own address")
            return
        }
        
        switch isNotificationTxNeededToSend {
        case false:
            createTransaction(customFee: customFee)
            if isCustomFee && customFee == nil {
                delegate?.didChooseCustomFee()
            } else {
                sendAfterPasscode()
            }
        case true:
            createNotificationTransaction(success: { notTxHash in
                var pcContact = self.contactsProvider.getOrCreatePaymentCodeContact(paymentCode: self.recipientString!)
                pcContact.notificationTxHash = notTxHash
                self.contact = pcContact
                self.createTransaction()
                self.sendAfterPasscode()
                return
            }, failure: { [weak self] (errorString) in
                let failureString = NSLocalizedString("Error \"\(errorString)\" when creation notification transaction", comment: "")
                self?.delegate?.didFailSendTransaction(text: failureString)
            })
        }
    }
    
    func loadFeeIfNeeded() {
        guard let _ = feeProvider?.getFee(size: (defaultsProvider?.commission)!) else {
            feeProvider?.downloadFee()
            return
        }
    }
    
    deinit {
        scanProvider.scannedString = ""
    }
}

// MARK: - PasscodeOutputDelegate

extension SendVM: PasscodeOutputDelegate {
    
    func didCompleteVerification() {
        PopupView.loading.showLoading()
        publish(success: { [weak self] successString in
            PopupView.loading.dismissLoading()
            let successString = NSLocalizedString("Success send funds", comment: "")
            self?.delegate?.didSendTransaction(text: successString)
            
            if var contact = self?.contact, let transaction = self?.tx {
                contact.txHashes.insert(UInt256S(transaction.txHash).data.hex)
                try? self?.contactsProvider.save(contact)
            }
        }) { [weak self] failureString in
            PopupView.loading.dismissLoading()
            self?.delegate?.didFailSendTransaction(text: failureString)
        }
    }
    
}

// MARK: - ContactsOutputDelegate
extension SendVM: ContactsOutputDelegate {
    
    func didSelectContact(_ contact: ContactProtocol) {
        self.recipientString = contact.uniqueValue
        self.contact = contact
    } 
}

public enum SendError: Error {
    case invalidAddress
}

extension SendError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return NSLocalizedString("Send address is invalid", comment: "")
        }
    }
}
