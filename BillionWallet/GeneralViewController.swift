
//  GeneralViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 27/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

fileprivate let syncStrings: [GeneralVM.SyncStatus : String] = [
    .connecting : "Connecting",
    .syncing : "Syncing",
    .synced : ""
]

class GeneralViewController: BaseViewController<GeneralVM>, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    enum Position: String {
        case top
        case center
        case bottom
    }
    
    weak var mainRouter: MainRouter?
    fileprivate let tweaking: CGFloat = 40
    fileprivate let centralBottomHeight: CGFloat = 0 // Change when add shedule
    
    fileprivate var bottomHeight: CGFloat!
    fileprivate var position: Position = .center
    fileprivate var gradientView: UIView!
    fileprivate var imageCache = NSCache<NSString,UIImage>()
    var noNetworkPopup: PopupView!
    
    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var lockViewBottomLabel: UILabel!
    @IBOutlet weak var balanceView: UIView?
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var syncingView: UIView?
    @IBOutlet weak var syncStatusLabel: UILabel!
    @IBOutlet weak var syncDotsLabel: UILabel!
    @IBOutlet weak var syncingLabel: UILabel?
    
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var filtersButton: UIButton!
    @IBOutlet weak var centralStackView: UIStackView!
    @IBOutlet weak var topCentralView: UIView!
    @IBOutlet weak var bottomCentralView: UIView!
    @IBOutlet weak var balanceNative: UILabel!
    @IBOutlet weak var balanceBits: UILabel!
    @IBOutlet weak var testnetView: UIView!
    @IBOutlet weak var txTableView: UITableView! {
        didSet {
            txTableView.register(UINib(nibName: "TransactionCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        }
    }
    @IBOutlet weak var shaduleTableView: UITableView!
    @IBOutlet var panGasture: UIPanGestureRecognizer!
    @IBOutlet weak var topTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    override func configure(viewModel: GeneralVM) {
        viewModel.delegate = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLockView()
        setupGradientView()
        setupBalance()
        setupTestnet()
        createPinIfNeeded()
        setupSyncProgress()
        showSyncProgress()
        viewModel.checkWalletDigest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        viewModel.getTransactions()
    }
    
    fileprivate func setupLockView() {
        let pinLockText = "with passcode"
        let touchIdLockText = "with Touch ID"
        lockViewBottomLabel.text = viewModel.isTouchIdEnabled ? touchIdLockText : pinLockText
        lockView.isHidden = !viewModel.isLocked
    }
    
    fileprivate func  setupGradientView() {
        gradientView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 350))
        gradientView.isUserInteractionEnabled = false
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientView.layer.insertSublayer(gradient, at: 0)
        view.addSubview(gradientView)
        view.bringSubview(toFront: gradientView)
        txTableView.contentInset.top = 83
    }
    
    fileprivate func setupBalance() {
        if let localeIso = viewModel.walletProvider?.manager.localCurrencyCode {
            balanceNative?.text = stringCurrency(from: viewModel.balance, localeIso: localeIso)
        }
    }
    
    fileprivate func setupTestnet() {
        if (viewModel.walletProvider?.manager.isTestnet)! {
            testnetView?.isHidden = false
        }
    }
    
    fileprivate func createPinIfNeeded() {
        if viewModel.passcode == nil {
            mainRouter?.showPasscodeView(passcodeCase: .createFirst, output: viewModel)
        }
    }
    
    fileprivate func setupSyncProgress() {
        progressView?.transform = CGAffineTransform(scaleX: 1, y: (balanceView?.frame.size.height)!/(progressView?.frame.size.height)!)
    }
    
    fileprivate func showSyncProgress() {
        setSyncViewIsShown(true)
        progressInc()
    }
    
    fileprivate func animateSync() {
        let options : UIViewAnimationOptions = [  ]
        UIView.animate(withDuration: 0.5, delay: 0.0, options: options, animations: { [weak self] in
            if let text = self?.syncDotsLabel.text {
                if text != "..." {
                    let newText = text + "."
                    self?.syncDotsLabel.text = newText
                } else {
                    self?.syncDotsLabel.text = ""
                }
            }
        }, completion: nil)
    }
    
    fileprivate func setSyncViewIsShown(_ shown: Bool) {
        UIApplication.shared.isIdleTimerDisabled = shown
        balanceView?.isHidden = shown
        syncingView?.isHidden = !shown
        progressView.isHidden = !shown
        balanceBits?.isHidden = shown
    }
    
    @objc fileprivate func progressInc() {
        let status = viewModel.currentSyncStatus()
        syncStatusLabel.text = NSLocalizedString(syncStrings[status] ?? "", comment: "")
        let syncProgress = Float(viewModel.currentSyncPercent())
        
        if status == .synced {
            self.setSyncViewIsShown(false)
        } else {
            animateSync()
            progressView.progress = syncProgress
#if DEBUG
            let currentBlock = viewModel.currentBlock()
            let estimatedBlock = viewModel.estimatedBlockHeight()
            syncingLabel?.text = String(format: "%ld / %ld", currentBlock.height, estimatedBlock)
#else
            syncingLabel?.text = viewModel.currentBlockDate()
#endif
            self.perform(#selector(progressInc), with: nil, afterDelay:0.5)
        }
    }
    
    // MARK: Actions
    @IBAction func receiveAction() {
        mainRouter?.showReceiveView()
    }
    
    @IBAction func sendAction() {
        mainRouter?.showSendView()
    }
    
    @IBAction func contactsAction() {
        let image = captureScreen(view: view)
        mainRouter?.showContactsView(output: nil, mode: .default, back:image)
    }
    
    @IBAction func filtersAction(_ sender: UIButton) {
        let fitstEnterDate = viewModel.defaultsProvider?.fitstEnterDate ?? Date()
        let filterView = FilterView(output: viewModel, firstEnterDate: fitstEnterDate, currentFilter: viewModel.currentFilter)
        UIApplication.shared.keyWindow?.addSubview(filterView)
    }
    
    @IBAction func settingsAction() {
        mainRouter?.showSettingsView()
    }
    
    @IBAction func lockButtonPressed(_ sender: UIButton) {
        mainRouter?.showPasscodeView(passcodeCase: .lock, output: nil)
    }
    
    @IBAction func walletButtonPressed(_ sender: UIButton) {
        let image = captureScreen(view: view)
        mainRouter?.showProfileView(back: image)
    }
    
    @IBAction func didDragPanel(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: view)
        
        var movingTop: Bool {
            return translation.y > 0
        }
        
        switch sender.state {
        case .began:
            bottomHeight = bottomTableConstraint.constant
        case .changed:
            
            guard bottomHeight - translation.y >= 0 else {
                return
            }
            
            bottomTableConstraint.constant = bottomHeight - translation.y
            
            view.layoutIfNeeded()
            
        case .ended:
            
            if abs(translation.y) > self.tweaking {
                performPositionChanging(movingTop: movingTop)
            } else {
                self.bottomTableConstraint.constant = self.bottomHeight
            }
            
        default:
            break
        }
    }
    
    fileprivate func performPositionChanging(movingTop: Bool) {
        var nextPosition = position
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            switch self.position {
            case .center:
                self.topCentralView.alpha = 0
                self.topCentralView.isHidden = true
                self.stackViewHeightConstraint.constant = 82
                if movingTop {
                    nextPosition = .top
                    self.gradientView.alpha = 0
                    self.txTableView.isScrollEnabled = true
                    self.bottomTableConstraint.constant = 0
                    self.filtersButton.alpha = 1
                    self.settingsButton.alpha = 0
                    let maxConstraint = self.view.frame.size.height - (82 + 10)
                    self.topTableConstraint.constant = min(CGFloat(82 * self.viewModel.filteredTransactions.count), maxConstraint)
                } else {
                    nextPosition = .bottom
                    self.gradientView.alpha = 0
                    self.txTableView.isScrollEnabled = false
                    self.bottomTableConstraint.constant = self.view.frame.size.height - (20 + 82)
                }
                
            case .bottom:
                nextPosition = .center
                self.gradientView.alpha = 1
                self.txTableView.isScrollEnabled = false
                self.centralPosition()
                
            case .top:
                nextPosition = .center
                self.gradientView.alpha = 1
                self.txTableView.isScrollEnabled = false
                self.centralPosition()
                self.filtersButton.alpha = 0
                self.settingsButton.alpha = 1
            }
            self.view.layoutIfNeeded()
            
        }, completion: { _ in
            self.scrollToBottom(animated: false)
            self.position = nextPosition
        })
    }
    
    
    fileprivate func calculateTxTableViewHeight() {
        let maxConstraint = centralStackView.frame.origin.y
        topTableConstraint.constant = min(CGFloat(82 * viewModel.filteredTransactions.count), maxConstraint)
    }
    
    fileprivate func scrollToBottom(animated: Bool) {
        if viewModel.filteredTransactions.count > 0 {
            txTableView.scrollToRow(at: IndexPath(item: viewModel.filteredTransactions.count-1, section: 0), at: .bottom, animated: animated)
        }
    }
    
    fileprivate func centralPosition() {
        bottomTableConstraint.constant = centralBottomHeight
        stackViewHeightConstraint.constant = 164
        topCentralView.alpha = 1
        topCentralView.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionCell
        let transaction = viewModel.filteredTransactions[indexPath.row]
        cell.configure(with: transaction)
        cell.tag = indexPath.row
        cell.delegate = self
        
        if let contact = transaction.contact {
            if let imageFromCache = imageCache.object(forKey: transaction.txHash.data.toHexString() as NSString) {
                cell.contactImageView.image = imageFromCache
            } else {
                DispatchQueue.global().async { [weak self] in
                    let image = contact.avatarImage
                    self?.imageCache.setObject(image, forKey: transaction.txHash.data.toHexString() as NSString)
                    DispatchQueue.main.async {
                        cell.contactImageView.image = image
                    }
                }
            }
        } else {
            cell.contactImageView.image = UIImage.init(named: "QRIcon")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTransactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 83
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch position {
        case .top:
            if self.txTableView.contentOffset.y >= self.txTableView.contentSize.height - self.txTableView.frame.size.height {
                performPositionChanging(movingTop: true)
            } else {
                self.txTableView.isScrollEnabled = true
            }
            
        default:
            break
        }
    }
}

// MARK: - TransactionCellDelegate

extension GeneralViewController: TransactionCellDelegate {
    
    func bubbleButtonPressed(_ sender: TransactionCell) {
        let image = captureScreen(view: view)
        mainRouter?.showTransactionDetails(transaction: viewModel.filteredTransactions[sender.tag], back: image)
    }
    
}

// MARK: - GeneralVMDelegate

extension GeneralViewController: GeneralVMDelegate {
    
    func didReceiveTransactions() {
        txTableView.reloadData()
        calculateTxTableViewHeight()
        view.layoutIfNeeded()
        scrollToBottom(animated: false)
    }
    
    func balanceDidChange(number: UInt64) {
        balanceBits?.text = viewModel.walletProvider?.manager.string(forAmount: Int64(number))
        balanceNative?.text = viewModel.walletProvider?.manager.localCurrencyString(forAmount: Int64(viewModel.balance))
    }
    
    func passcodeDidCreate(passcode: String) {
    }
    
    func didChangeLockStatus(_ isLocked: Bool) {
        setupLockView()
    }
    
    func didChangeIsTouchIdEnabled(_ isTouchIdEnabled: Bool) {
        setupLockView()
    }
    
    func didSelectFilter(_ value: Bool) {
        let normal = value ? #imageLiteral(resourceName: "FilterSelected") : #imageLiteral(resourceName: "Filter")
        filtersButton.setImage(normal, for: .normal)
        txTableView.reloadData()
    }
    
    func reachabilityDidChange(status: Bool) {
        if status {
            DispatchQueue.main.async {
                if (self.noNetworkPopup) == nil {
                    self.noNetworkPopup = PopupView.init(type: .cancel, labelString: NSLocalizedString("No network connection", comment:""))
                }
                UIApplication.shared.keyWindow?.addSubview(self.noNetworkPopup)
            }
        } else {
            if (noNetworkPopup) != nil {
                DispatchQueue.main.async {
                    self.noNetworkPopup?.removeFromSuperview()
                    self.noNetworkPopup = nil
                }
            }
        }
    }
}

