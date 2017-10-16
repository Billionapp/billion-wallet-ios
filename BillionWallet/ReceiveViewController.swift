//
//  ReceiveViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 01/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ReceiveViewController: BaseViewController<ReceiveVM>, ReceiveVMDelegate {
    
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var qrImageView: UIImageView?
    @IBOutlet private weak var addressLabel: UILabel?
    @IBOutlet private weak var amountTextField: UITextField?
    @IBOutlet private weak var copyButton: UIButton?
    @IBOutlet private weak var sendButton: UIButton?
    @IBOutlet private weak var importButton: UIButton?
    @IBOutlet private weak var sendFromFieldButton: UIButton?
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    weak var mainRouter: MainRouter?
    
    override func configure(viewModel: ReceiveVM) {
        viewModel.delegate = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.getSelfAddress()
        
        amountTextField?.layer.borderColor = UIColor.lightGray.cgColor
        amountTextField?.layer.borderWidth = 2
        amountTextField?.layer.halfHeightCornerRadius()
        amountTextField?.layer.sublayerTransform = CATransform3DMakeTranslation(15, 0, 0);
        amountTextField?.delegate = viewModel
        amountTextField?.becomeFirstResponder()
        qrImageView?.alpha = 0.7
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func updateQR() {
        if let qrImage:UIImage = viewModel.qrFromString() {
            qrImageView?.image = qrImage
        }
    }
    
    
    // MARK: Actions
    @IBAction func closeAction() {
        navigationController?.pop()
    }
    
    @IBAction func copyAddressAction() {
        UIPasteboard.general.string = viewModel.stringForQr//viewModel.address
        amountTextField?.resignFirstResponder()
        var labelText = "Address with request for the amount was copied to clipboard"
        if (viewModel.amount == 0) {
            labelText = "Address was copied to clipboard"
        }
        let popup = PopupView.init(type: .ok, labelString: NSLocalizedString(labelText, comment: ""))
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    @IBAction func sendAddressAction() {
        let controller = UIActivityViewController.init(activityItems: [viewModel.stringForQr as Any], applicationActivities: nil)
        self.present(controller, animated: true) {}
    }
    
    @IBAction func importPrivateKeyAction() {
        mainRouter?.showImportKeyView()
    }
    
    
    // MARK: Delegates binding
    func amountDidChange(text:String) {
        //updateQR()
        if viewModel.amount.compare(NSDecimalNumber.zero) == .orderedSame {
            titleLabel?.text = NSLocalizedString("Your address", comment: "")
            sendButton?.isEnabled = true
            importButton?.isEnabled = true
            sendFromFieldButton?.isEnabled = false
            viewModel.getSelfAddress()
            updateQR()
        } else {
            titleLabel?.text = "Amount request\n\(text)"
            sendButton?.isEnabled = false
            importButton?.isEnabled = false
            sendFromFieldButton?.isEnabled = true
            updateQR()
        }
    }
    
    func addressDidChange(text: String) {
        addressLabel?.text = text
        updateQR()
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let userInfo = notification.userInfo, let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            bottomConstraint?.constant = endFrame.size.height + 10
        }
    }
}
