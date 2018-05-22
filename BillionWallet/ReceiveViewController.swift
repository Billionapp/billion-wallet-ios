//
//  ReceiveViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ReceiveViewController: BaseViewController<ReceiveVM> {
    
    typealias LocalizedStrings = Strings.Receive
    
    @IBOutlet weak var yourAddressLabel: UILabel!
    @IBOutlet weak var bigQRView: UIView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var qrImageView: UIImageView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var copyButton: UIButton?
    @IBOutlet private weak var sendFromFieldButton: UIButton?
    @IBOutlet weak var amountPrefix: UILabel!
    weak var mainRouter: MainRouter?
    
    private var titledView = TitledView()
    
    override func configure(viewModel: ReceiveVM) {
        viewModel.delegate = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitledView()
        localize()
        viewModel.getSelfAddress()
        
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        amountTextField?.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.amountRequest, attributes: attributes)
        amountTextField?.layer.borderColor = UIColor.lightGray.cgColor
        amountTextField?.layer.borderWidth = 2
        amountTextField?.layer.halfHeightCornerRadius()
        updateAmountTextFieldInset()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        amountTextField?.setbillionKeyboard(delegate: viewModel, currency: Defaults())
        
        if UIDevice.current.model != .iPhone4 {
            amountTextField?.becomeFirstResponder()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAmountText(_ :)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.removeObserver(self)
        self.amountTextField?.unsetBillionKeyboard()
    }
    
    private func setupTitledView() {
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.subtitle
        titledView.closePressed = {
            self.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    private func localize() {
        yourAddressLabel.text = LocalizedStrings.yourAddress
        copyButton?.setTitle(LocalizedStrings.copyAddress, for: .normal)
    }
    
    private func generateTitle() -> String? {
        if Layout.model == .four {
            return viewModel.localAmountString
        } else {
            return LocalizedStrings.title + "\n" + viewModel.localAmountString
        }
    }
    
    func updateQR() {
        if let qrImage = viewModel.qrFromString() {
            if Layout.model == .five { //Strange bug on 5S device
                qrImageView.image = nil
            }
            qrImageView.image = qrImage
        }
    }
    
    private func copyAddress() {
        UIPasteboard.general.string = viewModel.address
        amountTextField?.resignFirstResponder()
        let labelText = LocalizedStrings.addressCopied
        let popup = PopupView.init(type: .ok, labelString: labelText)
        popup.delegate = self
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    private func copyPaymentRequest() {
        UIPasteboard.general.string = viewModel.sharingBip21String()
        amountTextField?.resignFirstResponder()
        let labelText = LocalizedStrings.paymentRequestCopied
        let popup = PopupView.init(type: .ok, labelString: labelText)
        popup.delegate = self
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    private func isRedundantFractionDigits(amount: String) -> Bool {
        let separator = Locale.current.decimalSeparator ?? "."
        guard let commaIndex = amount.index(of: Array(separator).first!) else { return false }
        let decimalPartIndex = amount.index(after: commaIndex)
        let decimalPartString = amount[decimalPartIndex...]
      
        if decimalPartString.count > viewModel.fractionDigits { return true}
        return false
    }
    
    // MARK: Actions
    @IBAction func copyAddressAction() {
        if viewModel.amount == 0 {
            copyAddress()
        } else {
            copyPaymentRequest()
        }
    }
    
    @IBAction func sendAddressAction() {
        let separator = Locale.current.decimalSeparator ?? "."
        guard amountTextField.text?.last != Array(separator).first! else { return }
        let controller = UIActivityViewController.init(activityItems: [viewModel.sharingBip21String() as Any], applicationActivities: nil)
        controller.completionWithItemsHandler = { _, finished, _, error in
            
            if !finished {
                if let error = error {
                    Logger.error(error.localizedDescription)
                }
                return
            }
            self.navigationController?.popToGeneralView()
            let popup = PopupView(type: .ok, labelString: LocalizedStrings.requestSent)
            UIApplication.shared.keyWindow?.addSubview(popup)
        }
        self.present(controller, animated: true) {}
    }
    
    //MARK - Notifications
    @objc func didChangeAmountText(_ notif: Notification) {
        guard let text = amountTextField?.text else { return }
        if viewModel.customKeyboardCurrencyState == .satoshi {
            if text == "0" {
                amountTextField?.text = ""
                return
            }
        }
        
        if isRedundantFractionDigits(amount: text) {
            amountTextField?.deleteBackward()
            return
        }
        
        if text.count < 13 {
            viewModel.amountTextDidChange(text: text)
        } else {
            amountTextField?.deleteBackward()
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if UIDevice.current.model == .iPhone4 {
            titledView.subtitle = nil
            bigQRView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if UIDevice.current.model == .iPhone4 {
            bigQRView.isHidden = false
        }
    }
}

//MARK: - TextField configuration
extension ReceiveViewController {
    func updateAmountTextFieldInset() {
        updatePrefixView()
        amountTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(40, 0, 0);
    }
    
    func updatePrefixView() {
        let stringForPrefix = (viewModel.customKeyboardCurrencyState == .satoshi) ? Strings.satoshiSymbol : viewModel.currencySymbol
        amountPrefix?.text = stringForPrefix
    }
}

//MARK: - PopupViewDelegate
extension ReceiveViewController: PopupViewDelegate {
    func viewDidDismiss() {
        amountTextField?.becomeFirstResponder()
    }
}

//MARK: - ReceiveVMDelegate
extension ReceiveViewController: ReceiveVMDelegate {
    func updateTextField(with satoshi: String) {
        amountTextField?.text = satoshi
    }
    
    func clearTextField() {
        amountTextField?.text = ""
    }
    
    func currencyDidChange() {
        amountDidChange(amount: viewModel.amount)
        updateAmountTextFieldInset()
    }
    
    func amountDidChange(amount: UInt64) {
        if viewModel.amount == 0 {
            titledView.title = LocalizedStrings.title
            titledView.subtitle = LocalizedStrings.subtitle
            viewModel.getSelfAddress()
            copyButton?.setTitle(LocalizedStrings.copyAddress, for: .normal)
            updateQR()
        } else {
            titledView.title = generateTitle()
            titledView.subtitle  = nil
            copyButton?.setTitle(LocalizedStrings.copyRequest, for: .normal)
            updateQR()
        }
    }
    
    func addressDidChange(text: String) {
        addressLabel.text = text
        updateQR()
    }
}
