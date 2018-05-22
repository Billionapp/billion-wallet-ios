//
//  TxFailureDetailsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TxFailureDetailsViewController: BaseViewController<TxFailureDetailsVM> {
    
    typealias LocalizedStrings = Strings.TxFailureDetails
    
    weak var router: MainRouter?
    
    private var titledView: TitledView!

    @IBOutlet private weak var confirmationsLabel: UILabel!
    @IBOutlet private weak var byCurrentRateLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel?
    @IBOutlet private weak var contactImageView: UIImageView!
    @IBOutlet private weak var bubbleImageView: UIImageView?
    @IBOutlet private weak var amountLabel: UILabel?
    @IBOutlet private weak var amountNowLabel: UILabel?
    @IBOutlet private weak var satAmountLabel: UILabel?
    @IBOutlet private weak var feeLabel: UILabel?
    @IBOutlet private weak var feeTitle: UILabel?
    @IBOutlet private weak var confirmationsCountLabel: UILabel?
    @IBOutlet private weak var addressLabel: UILabel?
    @IBOutlet private weak var addressTitle: UILabel?
    @IBOutlet private weak var retryButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var avatarBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var balanceBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubble: UIView!

    
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    override func configure(viewModel: TxFailureDetailsVM) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitledView()
        setTitles()
        setupBalanceView()
        localize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        setConstraints()
        animateBubble()
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = nil
        titledView.closePressed = {
            self.closeAction()
        }
        view.addSubview(titledView)
    }
    
    func setConstraints() {
        var adjustedCellY = CGFloat(0)
        let minY = titledView.subtitleLabel.frame.origin.y + titledView.subtitleLabel.frame.size.height + Layout.model.height * 3 + Layout.model.spacing
        if UIScreen.main.bounds.height - viewModel.cellY <= Layout.model.height * 2 + Layout.model.spacing * 2.67 {
            adjustedCellY = UIScreen.main.bounds.height - Layout.model.height * 2 - Layout.model.spacing * 2.65
            balanceBottomConstraint.constant = Layout.model.spacing / 2
        } else if viewModel.cellY <= minY {
            adjustedCellY = minY
        } else {
            adjustedCellY = viewModel.cellY
        }
        bubbleBottomConstraint.constant = UIScreen.main.bounds.height - adjustedCellY - Layout.model.spacing
        avatarBottomConstraint.constant = UIScreen.main.bounds.height - adjustedCellY
    }
    
    func animateBubble() {
        let origLeftConstraint = bubbleLeftConstraint.constant
        let origHeightConstraint = bubbleHeightConstraint.constant
        let origWidthConstraint = self.view.frame.width - Layout.model.spacing - contactImageView.frame.width - Layout.model
            .offset * 2
        bubbleLeftConstraint.constant = bubbleLeftConstraint.constant - Layout.model.spacing + 3
        bubbleHeightConstraint.constant = bubbleHeightConstraint.constant * 1 / 2
        bubbleWidthConstraint.constant = bubbleWidthConstraint.constant * 3 / 4 + (Layout.model.spacing - 3)*2
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            UIView.animate(withDuration: 0.15, animations: {
                self.bubbleLeftConstraint.constant = origLeftConstraint
                self.bubbleHeightConstraint.constant = origHeightConstraint
                self.bubbleWidthConstraint.constant = origWidthConstraint
                if self.bubbleBottomConstraint != nil {
                    self.bubbleBottomConstraint.constant = self.bubbleBottomConstraint.constant + Layout.model.spacing
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func animateBubbleReverseAndClose() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.bubbleHeightConstraint.constant = self.bubbleHeightConstraint.constant*1/3
            self.bubbleWidthConstraint.constant = self.bubbleWidthConstraint.constant*3/4
            self.bubble.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.navigationController?.popQuickly()
        })
    }
    
    // MARK: - Private methods
    private func setupBalanceView() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    private func localize() {
        byCurrentRateLabel.text = LocalizedStrings.byCurrentRate
        confirmationsLabel.text = LocalizedStrings.confirmations
        retryButton.setTitle(LocalizedStrings.retry, for: .normal)
        deleteButton.setTitle(LocalizedStrings.delete, for: .normal)
    }
    
    private func setTitles() {
        let interval = TimeInterval(viewModel.displayer.failureTx.identifier) ?? Date().timeIntervalSince1970
        let date = Date(timeIntervalSince1970: interval)
        timestampLabel?.text = date.humanReadable
        addressLabel?.text = LocalizedStrings.addressTitle
        addressTitle?.text = viewModel.displayer.address
        feeTitle?.text = LocalizedStrings.feeTitle
        contactImageView?.layer.standardCornerRadius()
        
        amountLabel?.text = viewModel.localCurrencyAmount
        amountNowLabel?.text = viewModel.localCurrencyAmountNow
        satAmountLabel?.text = viewModel.satoshiAmount
        
        if let contact = viewModel.displayer.connection {
            contactImageView.image = contact.avatarImage
            titledView.subtitle = contact.givenName
        }

        let fee = viewModel.displayer.failureTx.fee
        let feeAmount = Satoshi.amount(UInt64(fee))
        let localAmount = viewModel.localFeeAmount
        feeLabel?.text = String(format: LocalizedStrings.feeLabelFormat, localAmount, feeAmount)
    }
        
    // MARK: - Actions
    @IBAction func retryPressed(_ sender: UIButton) {
        if let contact = viewModel.displayer.connection as? PaymentCodeContactProtocol {
            router?.showSendInputContactView(contact: contact, failureTransaction: viewModel.displayer.failureTx, back: backImage)
        } else {
            let paymentRequest = PaymentRequest(address: viewModel.displayer.address, amount: UInt64(viewModel.displayer.failureTx.amount))
            router?.showSendInputAddressView(paymentRequest: paymentRequest, userPaymentRequest: nil, failureTransaction: viewModel.displayer.failureTx, back: backImage)
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        viewModel.deleteTransaction()
        navigationController?.pop()
    }
    
    @IBAction func closeAction() {
        animateBubbleReverseAndClose()
    }
}
