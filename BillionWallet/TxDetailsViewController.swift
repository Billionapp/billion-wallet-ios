//
//  TxDetailsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class TxDetailsViewController: BaseViewController<TxDetailsVM> {

    typealias LocalizedStrings = Strings.TxDetails
    
    private var bubbleInterval: CGFloat = 10

    @IBOutlet private weak var emptyTapRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var subtitleTapRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var addressTapRecognizer: UITapGestureRecognizer!
    
    @IBOutlet private weak var byCurentRateLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel?
    @IBOutlet private weak var subtitleLabel: UILabel!
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
    @IBOutlet private weak var commentTitleLabel: UILabel!
    @IBOutlet private weak var commentTextLabel: UILabel!
    @IBOutlet private weak var commentsView: UIView!
    @IBOutlet private weak var avatarBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var divFirstLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var divFirstRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var divSecondLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var divSecondRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubble: UIView!
    @IBOutlet private weak var confirmationsLabel: UILabel!
    
    weak var router: MainRouter?
    var backForBlur: UIImage?
    var cellY: CGFloat!
    
    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
        setGestures()
        setBlurBackground()
        viewModel.setupTransaction()
        removeSwipeDownGesture()
        addSwipeDown()
        setupBalanceView()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        setTitles()
        viewModel.getUserNoteIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        animateBubble()
    }
    
    override func configure(viewModel: TxDetailsVM) {
        viewModel.delegate = self
    }
    
    private func localize() {
        byCurentRateLabel.text = LocalizedStrings.byCurrentRate
    }
    
    private func setupBalanceView() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    // MARK: Actions
    @IBAction func closeAction() {
        animateBubbleReverseAndClose()
    }
    
    @IBAction func gotoWebLink() {
        viewModel.gotoWebLink()
    }
    
    @objc func copyTxIdAction() {
        UIPasteboard.general.string = viewModel.transactionHash
        let popup = PopupView(type: .ok, labelString: LocalizedStrings.copyTxIdPopup)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    @objc func copyAddressAction() {
        UIPasteboard.general.string = viewModel.recipientText
        let popup = PopupView(type: .ok, labelString: LocalizedStrings.copyAddressPopup)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    // MARK: Others
    func animateBubble() {
        let origLeftConstraint = bubbleLeftConstraint.constant
        let origHeightConstraint = bubbleHeightConstraint.constant
        let origWidthConstraint = self.view.frame.width - Layout.model.spacing * 3 - contactImageView.frame.width
        bubbleLeftConstraint.constant = bubbleLeftConstraint.constant - Layout.model.spacing + 3
        bubbleHeightConstraint.constant = bubbleHeightConstraint.constant * 1 / 4 + bubbleInterval * 2
        bubbleWidthConstraint.constant = bubbleWidthConstraint.constant * 3 / 4 + (Layout.model.spacing - 3)*2
        self.view.layoutIfNeeded()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            UIView.animate(withDuration: 0.15, animations: {
                self.bubbleLeftConstraint.constant = origLeftConstraint
                self.bubbleHeightConstraint.constant = origHeightConstraint
                self.bubbleWidthConstraint.constant = origWidthConstraint
                if self.bubbleBottomConstraint != nil {
                    self.bubbleBottomConstraint.constant = self.bubbleBottomConstraint.constant + self.bubbleInterval
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
    
    func setConstraints() {
        if UIScreen.main.bounds.height - cellY <= Layout.model.height + Layout.model.offset + Layout.model.spacing {
            cellY = UIScreen.main.bounds.height - Layout.model.height - Layout.model.offset - Layout.model.spacing
        } else if cellY <= Layout.model.height * 2 + Layout.model.offset + Layout.model.spacing * 3 {
            cellY = Layout.model.height * 2 + Layout.model.offset + Layout.model.spacing * 3
        }
        avatarBottomConstraint.constant = UIScreen.main.bounds.height-cellY
        if cellY - bubble.frame.size.height > subtitleLabel.frame.origin.y + subtitleLabel.frame.size.height {
            bubbleBottomConstraint.constant = UIScreen.main.bounds.height - cellY - bubbleInterval
        } else {
            self.view.removeConstraint(bubbleBottomConstraint)
            self.view.layoutIfNeeded()
            let constraint = NSLayoutConstraint.init(item: bubble,
                                                     attribute: .top,
                                                     relatedBy: .equal,
                                                     toItem: bubble.superview,
                                                     attribute: .top,
                                                     multiplier: 1,
                                                     constant: cellY-contactImageView.frame.size.height)
            self.view.addConstraint(constraint)
            self.view.layoutIfNeeded()
        }
        
        if viewModel.displayer.isReceived {
            divFirstLeftConstraint.constant = 5
            divSecondLeftConstraint.constant = 5
            divFirstRightConstraint.constant = 0
            divSecondRightConstraint.constant = 0
        }
    }
    
    func setGestures() {
        emptyTapRecognizer.addTarget(self, action: #selector(animateBubbleReverseAndClose))
        subtitleTapRecognizer.addTarget(self, action: #selector(copyTxIdAction))
        addressTapRecognizer.addTarget(self, action: #selector(copyAddressAction))
    }
    
    func setTitles() {
        // get ready for "moved" direction if user moves his funds between wallets
        switch viewModel.direction {
        case .received:
            titleLabel?.text = LocalizedStrings.titleReceived
            bubbleImageView?.image = UIImage(named: "BigBubbleGreen")?.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: .stretch)
            addressTitle?.text = LocalizedStrings.addressTitleSelf
        case .sent:
            titleLabel?.text = LocalizedStrings.titleSent
            bubbleImageView?.image = UIImage(named: "BigBubbleRed")?.resizableImage(withCapInsets: UIEdgeInsetsMake(20, 20, 20, 20), resizingMode: .stretch)
            addressTitle?.text = LocalizedStrings.addressTitleRecipient
        case .move:
            break
        }
        
        timestampLabel?.text = viewModel.displayer.time.humanReadable
        subtitleLabel?.text = viewModel.txSubtitle
        addressLabel?.text = viewModel.recipientText
        feeTitle?.text = LocalizedStrings.feeTitle
        confirmationsLabel.text = viewModel.confirmationsFormat        
        contactImageView?.layer.standardCornerRadius()
        if let contactImage = viewModel.avatarImage {
            contactImageView?.image = contactImage
        }
        
        amountLabel?.text = viewModel.displayer.localCurrencyAmount
        amountNowLabel?.text = viewModel.displayer.localCurrencyAmountNow
        satAmountLabel?.text = viewModel.displayer.satoshiAmount
        confirmationsCountLabel?.text = viewModel.displayer.confirmationsText
        
        if viewModel.direction == .sent {
            feeLabel?.isHidden = false
            feeTitle?.isHidden = false
            feeLabel?.text = String(format: LocalizedStrings.feeLabelFormat, viewModel.displayer.localFeeAmount)
        } else {
            feeLabel?.isHidden = true
            feeTitle?.isHidden = true
        }
    }
    
    func setBlurBackground() {
        if let backImage = backForBlur {
            let imageView = UIImageView(image: backImage)
            view.insertSubview(imageView, at: 0)
        }
    }
    
    func addSwipeDown() {
        let g = UISwipeGestureRecognizer(target: self, action: #selector(closeAction))
        g.direction = .down
        self.view.addGestureRecognizer(g)
    }
}

extension TxDetailsViewController: TxDetailsVMDelegate {
    func didReceiveNote(note: String) {
        if note.isEmpty {
            addressLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
            addressLabel?.text = LocalizedStrings.noComment
            addressTitle?.text = ""
        } else {
            addressLabel?.text = note
            addressTitle?.text = LocalizedStrings.commentTitle
        }
    }
    
    func transactionUpdated() {
        self.setTitles()
        viewModel.getUserNoteIfNeeded()
    }
}
