//
//  NotificationTxDetailsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class NotificationTxDetailsViewController: BaseViewController<NotificationTxDetailsVM> {
    
    typealias LocalizedStrings = Strings.NotificationDetails
    
    @IBOutlet private weak var confirmationsLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var emptyTapRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var subtitleTapRecognizer: UITapGestureRecognizer!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var contactImageView: UserAvatarSmallImageView!
    @IBOutlet private weak var localAmountLabel: UILabel!
    @IBOutlet private weak var satoshiAmountLabel: UILabel!
    @IBOutlet private weak var confirmationsCountLabel: UILabel!
    @IBOutlet private weak var avatarBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubbleLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var bubble: UIView!
    
    weak var router: MainRouter?
    private var titledView: TitledView!

    @IBOutlet weak var balanceViewContainer: UIView!
    private var billionBalanceView: BillionBalanceView!
    
    func addBalanceView(_ view: BillionBalanceView) {
        self.billionBalanceView = view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitledView()
        setTitles()
        removeSwipeDownGesture()
        addSwipeDown()
        setGestures()
        setupBalanceView()
        localize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(true)
        setConstraints()
        animateBubble()
    }

    override func configure(viewModel: NotificationTxDetailsVM) {
        
    }
    
    // MARK: - Private methods
    
    private func localize() {
        titleLabel.text = LocalizedStrings.networkFee
        confirmationsLabel.text = LocalizedStrings.confirmations
    }
    
    private func setupBalanceView() {
        billionBalanceView.frame =  balanceViewContainer.bounds
        balanceViewContainer.addSubview(billionBalanceView)
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.subtitle
        titledView.closePressed = {
            self.closeAction()
        }
        view.addSubview(titledView)
        titledView.layoutIfNeeded()
    }
    
    func setTitles() {
        timeLabel.text = viewModel.displayer.time.humanReadable
        localAmountLabel.text = viewModel.localCurrencyAmount
        satoshiAmountLabel.text = viewModel.satoshiAmount
        confirmationsCountLabel.text = viewModel.confirmations
        contactImageView.image = viewModel.contactAvatar
    }
    
    func setGestures() {
        emptyTapRecognizer.addTarget(self, action: #selector(closeAction))
        subtitleTapRecognizer.addTarget(self, action: #selector(copyTxIdAction))
        subtitleTapRecognizer.accessibilityElements = [titledView.subtitleLabel]
    }
    
    func addSwipeDown() {
        let g = UISwipeGestureRecognizer(target: self, action: #selector(closeAction))
        g.direction = .down
        self.view.addGestureRecognizer(g)
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
    
    func setConstraints() {
        
        let minY = titledView.subtitleLabel.frame.origin.y + titledView.subtitleLabel.frame.size.height + Layout.model.height + Layout.model.spacing
        
        if UIScreen.main.bounds.height - viewModel.cellY <= Layout.model.height + Layout.model.offset + Layout.model.spacing {
            viewModel.cellY = UIScreen.main.bounds.height - Layout.model.height - Layout.model.offset - Layout.model.spacing
        } else if viewModel.cellY <= minY {
            viewModel.cellY = minY
        }
        avatarBottomConstraint.constant = UIScreen.main.bounds.height - viewModel.cellY
        if viewModel.cellY - bubble.frame.size.height > titledView.subtitleLabel.frame.origin.y + titledView.subtitleLabel.frame.size.height {
            bubbleBottomConstraint.constant = UIScreen.main.bounds.height - viewModel.cellY - Layout.model.spacing
        } else {
            self.view.removeConstraint(bubbleBottomConstraint)
            self.view.layoutIfNeeded()
            let constraint = NSLayoutConstraint.init(item: bubble,
                                                     attribute: .top,
                                                     relatedBy: .equal,
                                                     toItem: bubble.superview,
                                                     attribute: .top,
                                                     multiplier: 1,
                                                     constant: viewModel.cellY - contactImageView.frame.size.height)
            self.view.addConstraint(constraint)
            self.view.layoutIfNeeded()
        }
        
    }
    
    // MARK: - Actions
    @IBAction func closeAction() {
        animateBubbleReverseAndClose()
    }
    
    @IBAction func gotoWebLink() {
        viewModel.gotoWebLink()
    }
    
    @objc func copyTxIdAction() {
        UIPasteboard.general.string = viewModel.displayer.txHashString
        let popup = PopupView(type: .ok, labelString: LocalizedStrings.copyNotifyTxIdPopup)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
}
