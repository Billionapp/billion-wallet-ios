//
//  SendInputAddressViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import AudioToolbox

class SendInputAddressViewController: BaseViewController<SendInputAddressVM>, UITextFieldDelegate, UIPreviewInteractionDelegate, UIViewControllerPreviewingDelegate {
    
    typealias LocalizedStrings = Strings.SendInput
  
    @IBOutlet weak var amountLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var clearAmountButton: UIButton!
    @IBOutlet private weak var receiverImageView: UIImageView!
    @IBOutlet private weak var amountTextField: UITextField!
    @IBOutlet private weak var amountView: UIView!
    @IBOutlet private weak var amountViewLabel: UILabel!
    @IBOutlet private weak var amountPrefix: UILabel!
    @IBOutlet private weak var sendFromFieldButton: TouchButtonView!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountBackgroundView: UIView!
    
    @IBOutlet private weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    @IBOutlet weak var keyboardheight: NSLayoutConstraint!
    var previewInteraction: UIPreviewInteraction!
    var conveyorView: TouchConveyorView!
    
    weak var mainRouter: MainRouter?
    private var titledView: TitledView!
    
    /// Offset between right edge of amountView and amount text field cursor
    private let textFeildCursorOffset: CGFloat = 40
    
    override func configure(viewModel: SendInputAddressVM) {
        viewModel.delegate = self
    }
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInputField()
        setupSendButton()
        setupBalanceView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        showKeyboard()
        
        navigationController?.delegate = self
        
        addKeyboardObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(self.showKeyboard), name: .UIApplicationDidBecomeActive, object: nil)
        viewModel.checkInputMode()
        amountTextField.text = viewModel.inputfield.getCommentText()
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
    
    private func addKeyboardObserver() {
        if !viewModel.inputfield.commentInput {
            NotificationCenter.default.addObserver(self, selector: #selector(didChangeAmountText(_ :)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        }
    }
    
    private func setupBalanceView() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    private func setupInputField() {
        amountBackgroundView.layer.borderColor = UIColor.lightGray.cgColor
        amountBackgroundView.layer.borderWidth = 2
        amountBackgroundView.layer.halfHeightCornerRadius()
        updateAmountTextFieldInset()
        setupTitledView()
        amountTextField.delegate = self
        amountTextField.autocorrectionType = .no
        amountView.layer.halfHeightCornerRadius()
        amountTextField.setbillionKeyboard(delegate: viewModel, currency: Defaults())
        bindToViewModel()
        viewModel.prefillAmountForPaymentRequest()
        viewModel.prefillAmountForUserPaymentRequest()
        viewModel.prefillAmountForFailureTransaction()
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.closePressed = {
            self.navigationController?.popToGeneralView()
        }
        
        view.addSubview(titledView)
    }
    
    private func bindToViewModel() {
        viewModel.inputAmountPrefix.bindAndFire { [unowned self] in
            self.updatePrefixView($0)
            self.viewModel.changeAmountString(self.amountTextField.text ?? "")
        }
        viewModel.title.bindAndFire { [unowned self] in self.titledView.title = $0 }
        titledView.subtitle = viewModel.subtitle
        self.receiverImageView.image = viewModel.receiverImageRepr
        viewModel.amountLabel.bindAndFire { [unowned self] in
            self.setAmountViewLabelText($0)
        }
    }
    
    private func setupSendButton() {
        /// FIXME: Todo dinamic blur
        /*
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: sendFromFieldButton)
        }
        previewInteraction = UIPreviewInteraction(view: sendFromFieldButton)
        previewInteraction.delegate = self
        */
        sendFromFieldButton.setDelegate(self)
        // TODO: Bussiness issue
        //let longTap = UILongPressGestureRecognizer.init(target: self, action: #selector(nextAction))
        //nextButton.addGestureRecognizer(longTap)
    }
    
    private func switchToCommentMode() {
        setupConveyorView()
        unhideAmountView()
        amountTextField.unsetBillionKeyboard()
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
        amountTextField.keyboardType = .default
        amountTextField.text = ""
        amountTextField.reloadInputViews()
        
        viewModel.inputfield.commentInput = true
    }
    
    // MARK: Conveyor
    fileprivate func setupConveyorView() {
        if conveyorView != nil {
            conveyorView.removeFromSuperview()
            conveyorView = nil
        }
        self.conveyorView = TouchConveyorView(frame: UIScreen.main.bounds)
        self.conveyorView.touchDelegate = self
        self.conveyorView.hitDelegate = self
        self.conveyorView.isUserInteractionEnabled = true
        UIApplication.shared.keyWindow!.addSubview(self.conveyorView)
    }
    
    fileprivate func unsetConveyorView() {
        if conveyorView != nil {
            conveyorView.removeFromSuperview()
            conveyorView = nil
        }
    }
    
    // MARK: Actions
    @IBAction func closeAction() {
        unsetConveyorView()
        navigationController?.popToGeneralView()
    }
    
    @IBAction func nextAction() {
        if !viewModel.isSynced {
            amountTextField.resignFirstResponder()
            let popUp = PopupView(type: .cancel, labelString: LocalizedStrings.sendBlocked)
            UIApplication.shared.keyWindow?.addSubview(popUp)
            return
        }
        hideBalance(true)
        unhideAmountView()
        amountTextField.unsetBillionKeyboard()
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
        amountTextField.keyboardType = .default
        amountTextField.text = ""
        amountTextField.reloadInputViews()
        viewModel.inputfield.commentInput = true
        switchToCommentMode()
    }
    
    @IBAction func clearAmountAction() {
        hideBalance(false)
        hideAmountView()
        viewModel.changeCurrencyState(.localCurrency)
        amountTextField.setbillionKeyboard(delegate: viewModel, currency: Defaults())
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeAmountText(_ :)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
        amountTextField.text = ""
        viewModel.changeAmountString("")
        amountTextField.reloadInputViews()
        
        viewModel.inputfield.commentInput = false
    }
    
    @IBAction func sendAction() {
        amountTextField.resignFirstResponder()
        if let text = amountTextField.text {
            viewModel.inputfield.setCommentText(text)
        }
        
        if let failureTx = viewModel.failureTransaction {
            mainRouter?.showChooseFeeAddressView(failureTx: failureTx, back: backImage, conveyor: conveyorView, userNote: amountTextField.text)
        } else if let userPaymentRequest = viewModel.userPaymentRequest {
            mainRouter?.showChooseFeeAddresView(userPaymentRequest: userPaymentRequest, back: backImage, conveyor: conveyorView, userNote: amountTextField.text)
        } else {
            mainRouter?.showChooseFeeAddressView(address: viewModel.receiverAddress, amount: viewModel.amount, back: backImage, conveyor: conveyorView, userNote: amountTextField.text)
        }
    }
    
    private func hideBalance(_ flag: Bool) {
        balanceViewContainer.isHidden = flag
    }
    
    func setAmountViewLabelText(_ text: String?) {
        let text = text ?? ""
        amountViewLabel.text = text
        let stringForViewLabel = String(format: LocalizedStrings.viewLabelFormat, text)
        let size = (stringForViewLabel as NSString).boundingRect(with: CGSize(width:CGFloat.greatestFiniteMagnitude, height:(self.amountTextField?.frame.size.height)!), options: .usesDeviceMetrics, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil).size
        let labelFrame =  amountViewLabel?.frame ?? CGRect()
        amountViewLabel?.frame = CGRect(x: labelFrame.origin.x, y: labelFrame.origin.y, width: size.width, height: labelFrame.size.height)
        let multiplier: CGFloat = clearAmountButton.isHidden ? 13 : 34
        let viewFrame =  amountView?.frame ?? CGRect()
        amountView?.frame = CGRect(x: viewFrame.origin.x, y: viewFrame.origin.y, width: size.width+multiplier, height: viewFrame.size.height)
    }
    
    func hideAmountView() {
        amountView.isHidden = true
        amountPrefix.isHidden = false
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        amountTextField.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.amountPlaceholder, attributes: attributes)
        nextButton.isHidden = false
        sendFromFieldButton.isHidden = true
        unsetConveyorView()
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
        return viewModel.inputfield.commentInput
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if viewModel.inputfield.commentInput {
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
        
        //Spacing between amountTextField and BillionKeyboard
        let spacing: CGFloat = 10
        bottomConstraint?.constant = keyboardHeight() + spacing
    }
    
    @objc
    func keyboardDidChangeFrame(_ notification: Notification) {
        let offsetBetweenKeyboardAndTextField: CGFloat = 10
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let height = keyboardRectangle.height
            if Layout.model.emojiKeybordHeight == height {
                keyboardheight.constant = keyboardRectangle.height + offsetBetweenKeyboardAndTextField
            } else {
                keyboardheight.constant = Layout.model.keyboardHeight + offsetBetweenKeyboardAndTextField
            }
        }
    }
    
    // MARK: UIPreviewInteractionDelegate
    func previewInteractionShouldBegin(_ previewInteraction: UIPreviewInteraction) -> Bool {
        return true
    }
    
    func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition transitionProgress: CGFloat, ended: Bool) {
        
        guard let bubbleView = previewInteraction.view else {
            previewInteraction.cancel()
            return
        }
        let gridStep = CGFloat(16.0)
        let touchBump = CGFloat(1.04)
        let w = (bubbleView.frame.width*touchBump / 2)
        let normalizedProgress = transitionProgress * ( gridStep - 4) / w  + touchBump
        
        if ended {
            UIView.animate(withDuration: 0.1, animations: {
                bubbleView.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform(scaleX: normalizedProgress, y: normalizedProgress)
                }
            }, completion: { _ in
                self.sendAction()
                previewInteraction.view?.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform.identity
                }
            })
        } else {
            bubbleView.subviews.forEach { (subview) in
                subview.transform = CGAffineTransform(scaleX: normalizedProgress, y: normalizedProgress)
            }
        }
    }
    
    func previewInteractionDidCancel(_ previewInteraction: UIPreviewInteraction) {
        previewInteraction.view?.subviews.forEach { (subview) in
            subview.transform = CGAffineTransform.identity
        }
    }
    
    //MARK: UIViewControllerPreviewingDelegate
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        previewingContext.sourceRect = self.sendFromFieldButton.frame
        let new = UIViewController()
        return new
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: nil)
    }
}

// MARK: - SendInputVMDelegate
extension SendInputAddressViewController: SendInputVMDelegate {
    func switchInputToCommentMode() {
        switchToCommentMode()
    }
    
    func updateTextField(with satoshi: String) {
        amountTextField.text = satoshi
    }
    
    func clearTextField() {
        amountTextField.text = ""
    }
    
    func deleteLastSymbol() {
        amountTextField.deleteBackward()
    }
    
    func didEnterLowAmount() {
        amountTextField.textColor = .white
        nextButton.isEnabled = false
    }
    
    func didEnterSafeInput() {
        amountTextField.textColor = .white
        nextButton.isEnabled = true
    }
    
    func didEnterUnsafeInput() {
        amountTextField.textColor = .orange
        nextButton.isEnabled = true
    }
    
    func didOverflow() {
        amountTextField.textColor = .darkGray
        nextButton.isEnabled = false
    }
    
    func didRecognizePaymentRequest() {
        switchToCommentMode()
        clearAmountButton.isHidden = true
        amountView.frame.size = CGSize(width: amountView.frame.size.width - clearAmountButton.frame.size.width, height: amountView.frame.size.height)
    }
    
    func didRecognizeFailureTransaction() {
        switchToCommentMode()
    }
}

// MARK: - TouchButtonViewDelegate
extension SendInputAddressViewController: TouchButtonViewDelegate {
    func touchEnded(_ sender: UIView) {
        self.sendAction()
    }
}

// MARK: - TouchConveyorDelegate
extension SendInputAddressViewController: TouchConveyorDelegate {
    func touchViewTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendFromFieldButton.touchesBegan(touches, with: event)
    }
    
    func touchViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendFromFieldButton.touchesMoved(touches, with: event)
        if touches.first!.force > 1.5 {
            viewModel.tapticService.selectionTaptic(capability:
                self.traitCollection.forceTouchCapability == .available)
            sendFromFieldButton.touchesEnded(touches, with: event)
            if self.navigationController?.topViewController == self {
                sendAction()
            }
        }
    }
    
    func touchViewTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendFromFieldButton.touchesEnded(touches, with: event)
        unsetConveyorView()
        if self.navigationController?.topViewController == self {
            sendAction()
        }
    }
    
    func touchViewTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        sendFromFieldButton.touchesCancelled(touches, with: event)
    }
}

extension SendInputAddressViewController: HitTestDelegate {
    func test(_ point: CGPoint, with event: UIEvent?) -> Bool {
        return sendFromFieldButton.convert(sendFromFieldButton.bounds, to: self.view).contains(point)
    }
}
