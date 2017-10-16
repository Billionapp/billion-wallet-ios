//
//  TxDetailsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TxDetailsViewController: BaseViewController<TxDetailsVM> {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel?
    @IBOutlet fileprivate weak var subtitleLabel: UILabel?
    @IBOutlet fileprivate weak var timestampLabel: UILabel?
    @IBOutlet fileprivate weak var contactImageView: UIImageView?
    @IBOutlet fileprivate weak var bubbleImageView: UIImageView?
    @IBOutlet fileprivate weak var amountLabel: UILabel?
    @IBOutlet fileprivate weak var bitAmountLabel: UILabel?
    @IBOutlet fileprivate weak var feeLabel: UILabel?
    @IBOutlet fileprivate weak var feeTitle: UILabel?
    @IBOutlet fileprivate weak var confirmationsLabel: UILabel?
    @IBOutlet fileprivate weak var addressLabel: UILabel?
    @IBOutlet fileprivate weak var addressTitle: UILabel?
    @IBOutlet fileprivate weak var balanceNative: UILabel?
    @IBOutlet fileprivate weak var balanceBits: UILabel?
    @IBOutlet fileprivate weak var addToContactButton: UIButton?
    
    weak var router: MainRouter?
    var backForBlur: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBlurBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        setTitles()
    }
    
    override func configure(viewModel: TxDetailsVM) {
        viewModel.delegate = self
    }
    
    // MARK: Actions
    @IBAction func closeAction() {
        navigationController?.pop()
    }
    
    @IBAction func addContactPressed(_ sender: UIButton) {
        if let partnerAddress = viewModel.partnerAddress() {
            router?.showAddContactAddressView(address: partnerAddress, txHash: viewModel.transaction.txHash)
        }
    }
    
    @IBAction func copyAddressAction() {
        UIPasteboard.general.string = viewModel.address ?? viewModel.transaction.contact?.uniqueValue
        let popup = PopupView.init(type: .ok, labelString: NSLocalizedString("The address was copied to the clipboard", comment:""))
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    // MARK: Others
    func setTitles() {
        if viewModel.transaction.isReceived {
            titleLabel?.text = viewModel.transaction.status.title ?? NSLocalizedString("Received", comment: "")
            bubbleImageView?.image = UIImage.init(named: "greenBigLeftBubble")
            addressTitle?.text = NSLocalizedString("wallet self address", comment: "")
        } else {
            titleLabel?.text = viewModel.transaction.status.title ?? NSLocalizedString("Sent", comment: "")
            bubbleImageView?.image = UIImage.init(named: "redBigRightBubble")
            addressTitle?.text = NSLocalizedString("recepient address", comment: "")
        }
        timestampLabel?.text = viewModel.transaction.timestamp?.humanReadable
        contactImageView?.layer.cornerRadius = 20
        contactImageView?.clipsToBounds = true
        viewModel.setAddressTitleAndAvatar()
        
        if let balance = viewModel.walletProvider?.manager.wallet?.balance {
            balanceBits?.text = viewModel.walletProvider?.manager.string(forAmount: Int64(balance))
            balanceNative?.text = viewModel.walletProvider?.manager.localCurrencyString(forAmount: Int64(balance))
        }
        
        if viewModel.transaction.contact == nil {
            addToContactButton?.isHidden = false
        } else if viewModel.transaction.contact != nil && (viewModel.transaction.contact?.isArchived)! {
            addToContactButton?.isHidden = false
        }
        
        amountLabel?.text = viewModel.transaction.localCurrencyAmount
        bitAmountLabel?.text = viewModel.transaction.bitsAmount
        confirmationsLabel?.text = ("\(viewModel.transaction.confirmations)")
        guard let fee = viewModel.walletProvider?.manager.wallet?.fee(for: viewModel.transaction.brTransaction) else {
            return
        }
        if fee == UINT64_MAX {
            return
        }
        guard let feeAmount = viewModel.walletProvider?.manager.string(forAmount: Int64(fee)) else {
            return
        }
        guard let localAmount = viewModel.walletProvider?.manager.localCurrencyString(forAmount: Int64(fee)) else {
            return
        }
        feeLabel?.text = ("\(localAmount) (\(feeAmount))")
    }
    
    func setBlurBackground() {
        if let backImage = backForBlur {
            let imageView = UIImageView(image: backImage)
            view.insertSubview(imageView, at: 0)
        }
    }

}

extension TxDetailsViewController: TxDetailsVMDelegate {
    func addressTitleDidSet(title: String?) {
        subtitleLabel?.text = title
        addressLabel?.text = title
    }
    func avatarDidSet(image: UIImage) {
        contactImageView?.image = image
    }
}
