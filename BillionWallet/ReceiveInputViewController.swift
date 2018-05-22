//
//  ReceiveInputViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ReceiveInputViewController: BaseViewController<ReceiveInputVM>, UITextFieldDelegate {
    
    typealias LocalizedStrings = Strings.ReceiveRequest
    
    @IBOutlet weak var amountBackgroundView: UIView!
    @IBOutlet weak var amountLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var receiverImageView: UIImageView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var amountView: UIView!
    @IBOutlet private weak var amountViewLabel: UILabel!
    @IBOutlet private weak var amountPrefix: UILabel!
    @IBOutlet private weak var sendFromFieldButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var contactNotLoadedIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var keyboardheight: NSLayoutConstraint!
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    private var titledView: TitledView!
    /// Offset between right edge of amountView and amount text field cursor
    private let textFeildCursorOffset: CGFloat = 40
    var commentInput: Bool = false
    weak var mainRouter: MainRouter?
    
    override func configure(viewModel: ReceiveInputVM) {
        viewModel.delegate = self
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        amountTextField.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.amountPlaceholder, attributes: attributes)
        amountBackgroundView.layer.borderColor = UIColor(red: 95/255, green: 106/255, blue: 137/255, alpha: 0.8).cgColor
        amountBackgroundView.layer.borderWidth = 2
        amountBackgroundView.layer.halfHeightCornerRadius()
        updateAmountTextFieldInset()
        setupTitledView()
        amountTextField.delegate = self
        amountTextField.autocorrectionType = .no
        amountView.layer.halfHeightCornerRadius()
        amountTextField.setbillionKeyboard(delegate: viewModel, currency: Defaults())
        contactNotLoadedIndicator.startAnimating()
        receiverImageView.isHidden = true
        bindToViewModel()
        setupBalanceView()
    }
    
    private func setupBalanceView() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.balanceTitle
        titledView.closePressed = {
            self.navigationController?.popToGeneralView()
        }
        view.addSubview(titledView)
    }
    
    func bindToViewModel() {
        viewModel.inputAmountPrefix.bindAndFire { [unowned self] in
            self.updatePrefixView($0)
            self.viewModel.changeAmountString(self.amountTextField.text ?? "")
        }
        viewModel.title.bindAndFire { [unowned self] in self.titledView.title = $0 }
        viewModel.subtitle.bindAndFire { [unowned self] in self.titledView.subtitle = $0 }
        viewModel.receiverImageRepr.bindAndFire { [unowned self] in
            if let image = $0 {
                self.receiverImageView.image = image
                self.receiverImageView.isHidden = false
                self.contactNotLoadedIndicator.stopAnimating()
                self.contactNotLoadedIndicator.isHidden = true
            }
        }
        viewModel.amountLabel.bindAndFire { [unowned self] in
            self.setAmountViewLabelText($0)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showKeyboard()
        
        navigationController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAmountText(_ :)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard), name: .UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidChangeFrame),
                                               name: NSNotification.Name.UIKeyboardDidChangeFrame,
                                               object: nil
        )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        self.amountTextField.unsetBillionKeyboard()
    }
    
    // MARK: Actions
    
    @IBAction func nextAction() {
        unhideAmountView()
        amountTextField.unsetBillionKeyboard()
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
        amountTextField.keyboardType = .default
        amountTextField.text = ""
        amountTextField.reloadInputViews()
        
        commentInput = true
    }
    
    @IBAction func clearAmountAction() {
        hideAmountView()
        amountTextField.setbillionKeyboard(delegate: viewModel, currency: Defaults())
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAmountText(_ :)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        amountTextField.text = ""
        viewModel.changeAmountString("")
        amountTextField.reloadInputViews()
        
        commentInput = false
    }
    
    @IBAction func sendAction() {
        viewModel.updatePriority()
        sendFromFieldButton.isEnabled = false
        amountTextField.resignFirstResponder()
        viewModel.didSendPressed(comment: amountTextField.text!)
    }
    
    func setAmountViewLabelText(_ text: String?) {
        let text = text ?? ""
        amountViewLabel.text = text
        let stringForViewLabel = String(format: LocalizedStrings.viewLabelFormat, text)
        let size = (stringForViewLabel as NSString).boundingRect(with: CGSize(width:CGFloat.greatestFiniteMagnitude, height:(self.amountTextField?.frame.size.height)!), options: .usesDeviceMetrics, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil).size
        let labelFrame =  amountViewLabel?.frame ?? CGRect()
        amountViewLabel?.frame = CGRect(x: labelFrame.origin.x, y: labelFrame.origin.y, width: size.width, height: labelFrame.size.height)
        let viewFrame =  amountView?.frame ?? CGRect()
        amountView?.frame = CGRect(x: viewFrame.origin.x, y: viewFrame.origin.y, width: size.width+34, height: viewFrame.size.height)
    }
    
    func hideAmountView() {
        amountView.isHidden = true
        amountPrefix.isHidden = false
        amountPrefix.isHidden = false
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        amountTextField.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.amountPlaceholder, attributes: attributes)
        nextButton.isHidden = false
        sendFromFieldButton.isHidden = true
        updateAmountTextFieldInset()
    }
    
    func unhideAmountView() {
        amountView.isHidden = false
        amountPrefix.isHidden = true
        amountTextField.textColor = .white
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        amountTextField.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.commentPlaceholder, attributes: attributes)
        nextButton.isHidden = true
        sendFromFieldButton.isHidden = false
        updateAmountTextFieldInset()
    }
    
    func updateAmountTextFieldInset() {
        if amountView.isHidden {
            amountLeftConstraint.constant = textFeildCursorOffset
        } else {
            amountLeftConstraint.constant = amountView.frame.size.width + 10
        }
        view.layoutIfNeeded()
    }
    
    func updatePrefixView(_ string: String) {
        amountPrefix.frame = CGRect(x: amountPrefix.frame.origin.x, y: amountPrefix.frame.origin.y, width: textFeildCursorOffset, height: amountPrefix.frame.size.height)
        amountPrefix.text = string
        updateAmountTextFieldInset()
    }
    
    // MARK: Text field delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return commentInput
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if commentInput {
            sendAction()
            return true
        }
        
        return false
    }
    
    @objc
    func didChangeAmountText(_ notif: Notification) {
        if let text = amountTextField?.text {
            // 12 digits limitations
            if text.count < 13 {
                viewModel.changeAmountString(text)
            } else {
                amountTextField.deleteBackward()
            }
        }
    }
    
    @objc
    func showKeyboard() {
        amountTextField.becomeFirstResponder()
    }
    
    @objc
    func keyboardDidChangeFrame(_ notification: Notification) {

        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let height = keyboardRectangle.height
            if Layout.model.emojiKeybordHeight == height {
                keyboardheight.constant = keyboardRectangle.height
            } else {
                keyboardheight.constant = Layout.model.keyboardHeight
            }
        }
    }
    
}

// MARK: - SendInputVMDelegate
extension ReceiveInputViewController: ReceiveInputVMDelegate {
    
    func showPasscodeView(amount: String, amountLocal: String, comment: String) {
         mainRouter?.showPasscodeView(passcodeCase: .custom(title: "Receive \(amountLocal)", subtitle: "\(amount)"), output: viewModel, reason: comment)
    }
    
    func deleteLastSymbol() {
        amountTextField.deleteBackward()
    }
    
    func clearTextField() {
        amountTextField.text = ""
    }
    
    func updateTextField(with satoshi: String) {
        amountTextField.text = satoshi
    }
    
    func didEnterAmount() {
        nextButton.isEnabled = viewModel.amount != 0
    }
    
    func didSentRequest() {
        navigationController?.popToGeneralView()
    }
    
    func didFailedSent(with error: Error) {
        sendFromFieldButton.isEnabled = true
        Logger.error(error.localizedDescription)
    }
    
    func didCancelVerification() {
        sendFromFieldButton.isEnabled = true
    }
}
