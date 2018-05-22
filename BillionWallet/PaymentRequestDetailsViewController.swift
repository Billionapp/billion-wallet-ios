//
//  PaymentRequestDetailsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 17/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class PaymentRequestDetailsViewController: BaseViewController<PaymentRequestDetailsVM> {
    
    typealias LocalizedStrings = Strings.PaymentRequest
    
    @IBOutlet fileprivate weak var emptyTapRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var bubble: UIView!
    @IBOutlet private weak var avatarIcon: UIImageView!
    @IBOutlet private weak var bubbleImage: UIImageView!
    @IBOutlet private weak var bubbleTitle: UILabel!
    @IBOutlet weak var amounLabel: UILabel!
    @IBOutlet weak var btcAmountLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet fileprivate weak var bubbleBottomConstraint: NSLayoutConstraint!
    weak var router: MainRouter?
    
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    private var titledView: TitledView!
    
    override func configure(viewModel: PaymentRequestDetailsVM) {
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitledView()
        setupBubbles()
        setConstraints()
        setGestures()
        setupButtonTexts()
        updateViewForRequestState()
        setupBalanceView()
        amounLabel.text = viewModel.displayer.title
        btcAmountLabel.text = viewModel.displayer.subtitle
        
        if let timeInterval = TimeInterval(viewModel.displayer.userPaymentRequest.identifier) {
            let date = Date(timeIntervalSince1970: timeInterval)
            timestampLabel.text = date.humanReadable
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        animateBubble()
    }
    
    func setGestures() {
        emptyTapRecognizer.addTarget(self, action: #selector(close))
    }
    
    private func setupBalanceView() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    private func setupBubbles() {
        bubbleImage.image = UIImage(named: "BubbleGray")
        avatarIcon.image = viewModel.avatarImage
        bubbleTitle.text = LocalizedStrings.bubbleTitle
    }
    
    // MARK: - Private methods
    
    private func setupButtonTexts() {
        let confirmText = LocalizedStrings.confirmButtonText
        let declineText = LocalizedStrings.declineButtonText
        let deleteText = LocalizedStrings.deleteButtonText
        
        confirmButton.setTitle(confirmText, for: .normal)
        declineButton.setTitle(declineText, for: .normal)
        deleteButton.setTitle(deleteText, for: .normal)
    }
    
    private func updateViewForRequestState() {
        if viewModel.displayer.userPaymentRequest.state == .declined {
            confirmButton.isHidden = true
            declineButton.isHidden = true
            deleteButton.isHidden = false
            titledView.title = LocalizedStrings.receiverRequestDeclinedTitle
        } else {
            confirmButton.isHidden = false
            declineButton.isHidden = false
            deleteButton.isHidden = true
            titledView.title = LocalizedStrings.receiverRequestTitle
        }
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.receiverRequestTitle
        titledView.subtitle = nil
        titledView.closePressed = {
            self.close()
        }
        view.addSubview(titledView)
    }
    
    func setConstraints() {
        let minY = titledView.subtitleLabel.frame.origin.y + titledView.subtitleLabel.frame.size.height + Layout.model.height + Layout.model.spacing
        if UIScreen.main.bounds.height - viewModel.cellY <= Layout.model.height*2 + Layout.model.offset + Layout.model.spacing*2 {
            viewModel.cellY = UIScreen.main.bounds.height - Layout.model.height*2 - Layout.model.offset - Layout.model.spacing*2
        } else if viewModel.cellY <= minY {
            viewModel.cellY = minY
        }
        bubbleBottomConstraint.constant = UIScreen.main.bounds.height - viewModel.cellY
    }
    
    private func animateBubble() {
        let gridStep = Layout.model.spacing
        let bubbleOffset = CGFloat(5.0)
        let touchBump = CGFloat(1.04)
        let w = (bubble.frame.width - bubbleOffset)
        let scale = ( gridStep / w ) + touchBump
        bubble.subviews.forEach { (subview) in
            subview.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.25,
                       initialSpringVelocity: 5,
                       options: UIViewAnimationOptions.curveEaseInOut,
                       animations: {
                        
                        self.bubble.subviews.forEach { (subview) in
                            subview.transform = CGAffineTransform.identity
                        }
        }, completion: nil)
    }
    
    @objc private func close() {
        self.navigationController?.pop()
    }
    
    // MARK: - Actions
    @IBAction func confirmPressed(_ sender: UIButton) {
        viewModel.calculateMaxSendAmount()
    }
    
    @IBAction func declinePressed(_ sender: UIButton) {
        viewModel.declineRequest()
        close()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        viewModel.deleteRequest()
        close()
    }
}

extension PaymentRequestDetailsViewController: PaymentRequestDetailsVMDelegate {
    
    func didOverflow() {
        let popup = PopupView(type: .cancel, labelString: LocalizedStrings.insufficientBalanceError)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    func didEnterCorrectAmount() {
        let paymentRequest = PaymentRequest(address: viewModel.displayer.userPaymentRequest.address, amount: viewModel.displayer.amount)
        if let contact = viewModel.getContact() {
            router?.showSendInputContactView(displayer: viewModel.displayer, contact: contact, back: backImage)
        } else {
            router?.showSendInputAddressView(paymentRequest: paymentRequest, userPaymentRequest: viewModel.displayer.userPaymentRequest, failureTransaction: nil, back: backImage)
        }
    }
    
}
