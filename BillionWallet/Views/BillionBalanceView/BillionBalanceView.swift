//
//  BillionBalanceView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class BillionBalanceView: UIView {
    
    private var viewModel: BillionBalanceVMProtocol!
    private var syncProgress: VerticalProgressIndicator!
    private var lockSyncProgress: VerticalProgressIndicator!
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet private weak var progressTintView: UIView!
    @IBOutlet private weak var lockProgressTintView: UIView!
    @IBOutlet private var lockedView: UIView!
    @IBOutlet private var balanceView: UIView!
    @IBOutlet private var syncView: UIView!
    
    // Locked view
    @IBOutlet private weak var unlockLabel: UILabel!
    @IBOutlet private weak var billionLabel: UILabel!
    @IBOutlet private weak var biometricsLabel: UILabel!
    
    // Balance view
    @IBOutlet weak var yourBalanceLabel: UILabel!
    @IBOutlet private weak var localBalanceLabel: UILabel!
    @IBOutlet private weak var btcBalanceLabel: UILabel!
    
    // Sync view
    @IBOutlet private weak var syncingLabelConstraint: NSLayoutConstraint!
    @IBOutlet private weak var syncingLabel: UILabel!
    @IBOutlet private weak var indicatorView: UIView!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        configure()
    }
    
    private func xibSetup() {
        view = loadViewFromXib()
        addSubview(view)
        addFillerSubview(view)
    }
    
    private func loadViewFromXib() -> UIView {
        let nib = UINib(nibName: String(describing: type(of: self)).nibName(), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return view
    }
    
    private func configure() {
        self.view.backgroundColor = .black
        self.view.layer.cornerRadius = Layout.model.cornerRadius
        self.view.layer.masksToBounds = true
        self.view.applyGradient(colours: [Color.buttonTop, Color.buttonBottom])
        
        self.lockedView.layer.cornerRadius = Layout.model.cornerRadius
        self.lockedView.layer.masksToBounds = true
        self.lockedView.applyGradient(colours: [Color.buttonTop, Color.buttonBottom])
        
        self.progressTintView.layer.cornerRadius = Layout.model.cornerRadius
        self.lockProgressTintView.layer.cornerRadius = Layout.model.cornerRadius
        
        self.addSubview(progressTintView)
        self.addSubview(balanceView)
        self.addSubview(syncView)
        self.addSubview(lockedView)
        
        lockedView.isHidden = true
        syncView.isHidden = true
        balanceView.isHidden = false
        
        setupSyncIndicator()
    }
    
    private func setupSyncProgress() {
        syncProgress = VerticalProgressIndicator()
        syncProgress.setup(on: progressTintView)
        syncProgress.setProgress(0.0)
        lockSyncProgress = VerticalProgressIndicator()
        lockSyncProgress.setup(on: lockProgressTintView)
        lockSyncProgress.setProgress(0.0)
    }
    
    private func setupSyncIndicator() {
        updateSyncLabel()
        
        let factor = indicatorView.frame.size.width / indicator.frame.size.width
        indicator.transform = CGAffineTransform(scaleX: factor, y: factor);
        indicator.center = indicatorView.center
    }
    
    private func updateSyncLabel() {
        let status = syncingLabel.text ?? ""
        let size = (status + "  " as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 12), options: .usesDeviceMetrics, attributes: [NSAttributedStringKey.font: syncingLabel.font], context: nil).size
        syncingLabelConstraint.constant = size.width
    }
    
    private func bindToViewModel() {
        setupSyncProgress()
        
        unlockLabel.text = viewModel.unlockText
        billionLabel.text = viewModel.billionText
        biometricsLabel.bindNow(to: viewModel.biometricsText)
        
        
        yourBalanceLabel.text = viewModel.yourBalanceText
        localBalanceLabel.bindNow(to: viewModel.localBalanceText)
        btcBalanceLabel.bindNow(to: viewModel.btcBalanceText)
        
        syncingLabel.bindNow(to: viewModel.statusText)
        progressLabel.bindNow(to: viewModel.progressText)
        dateLabel.bindNow(to: viewModel.blockDateText)
        
        if viewModel.isTestnet {
            localBalanceLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            btcBalanceLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        }
        
        viewModel.delegate = self
        
        self.viewModel.didBindToView()
    }
    
    func setVM(_ viewModel: BillionBalanceVMProtocol) {
        self.viewModel = viewModel
        self.bindToViewModel()
    }
}

extension BillionBalanceView: BillionBalanceVMDelegate {
    func didStartConnecting() {
        updateSyncLabel()
    }
    
    func didStartSyncing() {
        UIApplication.shared.isIdleTimerDisabled = true
        indicator.startAnimating()
        updateSyncLabel()
        syncView.isHidden = false
        balanceView.isHidden = true
    }
    
    func syncProgress(_ progress: Float) {
        updateSyncLabel()
        syncProgress.setProgress(progress)
        lockSyncProgress.setProgress(progress)
    }
    
    func didEndSyncing() {
        UIApplication.shared.isIdleTimerDisabled = false
        indicator.stopAnimating()
        syncView.isHidden = true
        balanceView.isHidden = false
        syncProgress.setProgress(0.0)
        lockSyncProgress.setProgress(0.0)
    }
    
    func didChangeLockStatus(to isLocked: Bool) {
        lockedView.isHidden = !isLocked
    }
}
