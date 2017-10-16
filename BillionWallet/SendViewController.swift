//
//  SendViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SendViewController: BaseViewController<SendVM>, UITextFieldDelegate {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var qrImageView: UIImageView?
    @IBOutlet fileprivate weak var recipientLabel: UILabel?
    @IBOutlet fileprivate weak var amountTextField: UITextField?
    @IBOutlet fileprivate weak var amountView: UIView?
    @IBOutlet fileprivate weak var amountViewLabel: UILabel?
    @IBOutlet private weak var scanQrButton: UIButton?
    @IBOutlet private weak var sendToAddressFromBufferButton: UIButton?
    @IBOutlet fileprivate weak var sendFromFieldButton: UIButton?
    @IBOutlet fileprivate weak var nextButton: UIButton?
    @IBOutlet fileprivate weak var sendToContact: UIButton?
    @IBOutlet private weak var balanceNative: UILabel?
    @IBOutlet private weak var balanceBits: UILabel?
    @IBOutlet private weak var balanceView: UIView?
    @IBOutlet weak var contactItem: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    weak var mainRouter: MainRouter?
    
    override func configure(viewModel: SendVM) {
        viewModel.delegate = self
        viewModel.loadFeeIfNeeded()
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        amountTextField?.layer.borderColor = UIColor.lightGray.cgColor
        amountTextField?.layer.borderWidth = 2
        amountTextField?.layer.halfHeightCornerRadius()
        amountTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0);
        amountTextField?.delegate = viewModel
        amountTextField?.autocorrectionType = .no
        amountView?.layer.halfHeightCornerRadius()
        scanQrButton?.alignVertical()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let balanceInteger = viewModel.walletProvider?.manager.wallet?.balance {
            balanceBits?.text = viewModel.walletProvider?.manager.string(forAmount: Int64(balanceInteger))
            let localBalance = viewModel.walletProvider?.manager.localCurrencyString(forAmount: Int64(balanceInteger))
            balanceNative?.text = localBalance
        }

        if viewModel.scanProvider.scannedString != "" {
            viewModel.setFromProvider()
        }
        addImageGesture()
    }
    
    func updateQR() {
        if let qrImage:UIImage = viewModel.qrFromString() {
            qrImageView?.image = qrImage
        }
    }
    
    func addImageGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openClearModal))
        self.qrImageView?.addGestureRecognizer(tap)
    }
    
    
    // MARK: Actions
    @IBAction func closeAction() {
        navigationController?.popToGeneralView()
    }
    
    @IBAction func scanQrAction() {
        mainRouter?.showScanView(isPrivate: false)
    }
    
    @IBAction func sendToAddressFromBufferAction() {
        viewModel.pasteFromClipboard()
    }
    
    @IBAction func nextAction() {
        amountView?.isHidden = false
        amountTextField?.placeholder = NSLocalizedString("Comment ...", comment: "")
        amountTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(15+(amountView?.frame.size.width)!, 0, 0);
        nextButton?.isHidden = true
        sendFromFieldButton?.isHidden = false
        amountTextField?.delegate = self
        amountTextField?.keyboardType = .default
        amountTextField?.text = ""
        amountTextField?.reloadInputViews()
    }
    
    @IBAction func clearAmountAction() {
        viewModel.amount = 0
        amountTextField?.placeholder = NSLocalizedString("Enter amount", comment: "")
        amountTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0);
        nextButton?.isHidden = false
        sendFromFieldButton?.isHidden = true
        amountView?.isHidden = true
        amountTextField?.delegate = viewModel
        amountTextField?.keyboardType = .decimalPad
        amountTextField?.text = ""
        amountTextField?.reloadInputViews()
    }
    
    @IBAction func addToContactsPressed(_ sender: UIButton) {
        let image = captureScreen(view: view)
        mainRouter?.showContactsView(output: viewModel, mode: .pick, back: image)
    }
    
    @IBAction func sendAction() {
        amountTextField?.resignFirstResponder()
        viewModel.send()
    }
    
    func hideButtonsArea() {
        scanQrButton?.isHidden = true
        sendToContact?.isHidden = true
        contactItem.isHidden = true
        sendToAddressFromBufferButton?.isHidden = true
        amountTextField?.isHidden = false
        nextButton?.isHidden = false
        balanceView?.isHidden = false
        amountTextField?.becomeFirstResponder()
    }
    
    func showButtonsArea() {
        scanQrButton?.isHidden = false
        sendToContact?.isHidden = false
        contactItem.isHidden = false
        sendToAddressFromBufferButton?.isHidden = false
        amountTextField?.isHidden = true
        nextButton?.isHidden = true
        balanceView?.isHidden = true
        amountTextField?.resignFirstResponder()
    }
    
    @objc func openClearModal() {
        if let image = qrImageView?.image,
            let address = viewModel.address {
            amountTextField?.resignFirstResponder()
            let clearModalView = ClearCodeModalView.init(address:address, image:image, viewModel: viewModel)
            UIApplication.shared.keyWindow?.addSubview(clearModalView)
        }
    }
    
    func updateAmountView(size: CGSize) {
        let labelFrame =  amountViewLabel?.frame ?? CGRect()
        amountViewLabel?.frame = CGRect(x: labelFrame.origin.x, y: labelFrame.origin.y, width: size.width, height: labelFrame.size.height)
        let viewFrame =  amountView?.frame ?? CGRect()
        amountView?.frame = CGRect(x: viewFrame.origin.x, y: viewFrame.origin.y, width: size.width+34, height: viewFrame.size.height)
    }
    
    func hideAmountView() {
        amountView?.isHidden = true
    }
    
    // MARK: Text field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.length == 0 { //adding character
            self.viewModel.txComment = "\(textField.text ?? "")\(string)"
            return true
        } else { //erase last character
            if range.location == 0  { //all characters was erased
                self.viewModel.txComment = ""
            } else {
                let text = textField.text ?? ""
                self.viewModel.txComment = String(text.characters.dropLast())
            }
            
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendAction()
        return true
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo, let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            bottomConstraint?.constant = endFrame.size.height + 10
        }
    }
}

extension SendViewController: SendVMDelegate {

    func didSendTransaction(text: String) {
        showPopup(type: .ok, title: text)
        closeAction()
    }
    
    func didFailSendTransaction(text: String) {
        showPopup(type: .cancel, title: text)
        closeAction()
    }
    
    func recipientDidChange(newRecipient: String) {
        if newRecipient != "" {
            self.recipientLabel?.text = newRecipient
            updateQR()
            hideButtonsArea()
        } else {
            self.recipientLabel?.text = NSLocalizedString("Select the recipient. Scan the QR code using the camera, remove the QR code from the pictures or send information to from the clipboard", comment: "")
            self.qrImageView?.image = nil
            showButtonsArea()
        }
    }

    func amountDidChange(amount: UInt64) {
        if amount == 0 {
            self.titleLabel?.text = NSLocalizedString("Send", comment: "")
            self.nextButton?.isEnabled = false
            hideAmountView()
        } else {
            let currency = CurrencyFactory.currencyWithCode(viewModel.walletProvider!.manager.localCurrencyCode ?? "USD")
            let converter = FiatConverter(currency: currency!, ratesSource: viewModel.ratesProvider)
            let localAmountString = converter.fiatStringForBtcValue(amount)
            self.titleLabel?.text = "Send\n\(localAmountString)"
            self.amountViewLabel?.text = localAmountString
            self.nextButton?.isEnabled = true
            let stringForViewLabel = "  \(localAmountString)  "
            let size = (stringForViewLabel as NSString).boundingRect(with: CGSize(width:CGFloat.greatestFiniteMagnitude, height:(self.amountTextField?.frame.size.height)!), options: .usesDeviceMetrics, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil).size
            updateAmountView(size: size)
            checkForFunding()
        }
    }
    
    func setTextFieldFromAmount(amount: UInt64) {
        let currency = CurrencyFactory.currencyWithCode(viewModel.walletProvider!.manager.localCurrencyCode ?? "USD")
        let converter = FiatConverter(currency: currency!, ratesSource: viewModel.ratesProvider)
        let amountForField = converter.convertToFiat(btcValue: amount)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        amountTextField?.text = formatter.string(from: amountForField as NSDecimalNumber)
    }
    
    func didChooseCustomFee() {
        mainRouter?.showCustomFeeView(transaction: viewModel.tx) { [weak self] fee in
            self?.viewModel.send(customFee: fee)
        }
    }
    
    func checkForFunding() {
        if let balance = viewModel.walletProvider?.manager.wallet?.balance {
            let bitsEnterAmount = viewModel.amount
            if balance < bitsEnterAmount {
                amountTextField?.textColor = UIColor.darkGray
                self.nextButton?.isEnabled = false
            } else {
                amountTextField?.textColor = UIColor.white
                self.nextButton?.isEnabled = true
            }
        }
    }
    
    func didReceiveContact(contact: ContactProtocol) {
        if let imageData = contact.avatarData {
            qrImageView?.image = UIImage(data: imageData, scale:1.0)
            qrImageView?.layer.cornerRadius = 20
            qrImageView?.layer.masksToBounds = true
        }
        recipientLabel?.text = contact.displayName
    }
    
    func showPasscodeView() {
        mainRouter?.showPasscodeView(passcodeCase: .custom(title: "Enter Passcode", subtitle: "Enter your passcode to proceed"), output: viewModel)
    }
}

extension CALayer {
    func halfHeightCornerRadius() {
        self.cornerRadius = self.frame.size.height/2
    }
}

public extension UIViewController {
    func showPopup(type: PopupType, title: String) {
        let popup = PopupView.init(type: type, labelString: title)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
}

fileprivate extension UIButton {
    
    func alignVertical(spacing: CGFloat = 6.0) {
        guard let imageSize = self.imageView?.image?.size,
            let text = self.titleLabel?.text,
            let font = self.titleLabel?.font
            else { return }
        self.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0.0)
        let labelString = NSString(string: text)
        let titleSize = labelString.size(withAttributes: [NSAttributedStringKey.font: font])
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing), left: 0.0, bottom: 0.0, right: -titleSize.width)
        let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0;
        self.contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
    }
}
