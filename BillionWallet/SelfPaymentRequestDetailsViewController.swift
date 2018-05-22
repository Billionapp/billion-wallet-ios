//
//  SelfPaymentRequestDetailsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SelfPaymentRequestDetailsViewController: BaseViewController<SelfPRVMProtocol> {
    
    typealias LocalizedStrings = Strings.PaymentRequest
    
    private var titledView: TitledView!
    
    @IBOutlet fileprivate weak var emptyTapRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var bubble: UIView!
    @IBOutlet private weak var avatarIcon: UIImageView!
    @IBOutlet private weak var bubbleImage: UIImageView!
    @IBOutlet private weak var bubbleTitle: UILabel!
    @IBOutlet private weak var amounLabel: UILabel!
    @IBOutlet private weak var btcAmountLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet fileprivate weak var bubbleBottomConstraint: NSLayoutConstraint!
    
    weak var router: MainRouter?
    
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }

    override func configure(viewModel: SelfPRVMProtocol) {
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitledView()
        setupBubbles()
        setConstraints()
        setGestures()
        setupButtonTexts()
        bindToVM()
        setupBalanceView()
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
        bubbleImage.image = UIImage(named: "BubbleGray")?.withHorizontallyFlippedOrientation()
        avatarIcon.image = viewModel.avatarImage
        bubbleTitle.text = LocalizedStrings.bubbleTitle
    }
    
    private func bindToVM() {
        amounLabel.text = viewModel.title
        btcAmountLabel.text = viewModel.subtitle
        timestampLabel.text = viewModel.timestamp
        avatarIcon.image = viewModel.avatarImage
        
        setupViewForRequestState()
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.sentRequestTitle
        titledView.subtitle = nil
        titledView.closePressed = {
            self.close()
        }
        view.addSubview(titledView)
    }
    
    private func setupButtonTexts() {
        let cancelText = LocalizedStrings.cancelButtonText
        let deleteText = LocalizedStrings.deleteButtonText
        
        cancelButton.setTitle(cancelText, for: .normal)
        deleteButton.setTitle(deleteText, for: .normal)
    }
    
    private func setupViewForRequestState() {
        if viewModel.isRejected {
            cancelButton.isHidden = true
            deleteButton.isHidden = false
            titledView.title = LocalizedStrings.requestRejected
        } else {
            cancelButton.isHidden = false
            deleteButton.isHidden = true
            titledView.title = LocalizedStrings.sentRequestTitle
        }
    }
    
    func setConstraints() {
        let minY = titledView.subtitleLabel.frame.origin.y + titledView.subtitleLabel.frame.size.height + Layout.model.height + Layout.model.spacing*2
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
    @IBAction func cancelPressed(_ sender: UIButton) {
        viewModel.cancelRequest()
        close()
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        viewModel.deleteRequest()
        close()
    }
}

// MARK: - SelfPRDetailsVMDelegate

extension SelfPaymentRequestDetailsViewController: SelfPRDetailsVMDelegate {
    func didCancelRequest() {
        close()
    }
}
