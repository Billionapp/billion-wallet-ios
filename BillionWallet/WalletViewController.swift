//
//  WalletViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class WalletViewController: BaseViewController<WalletVM> {
    
    weak var router: MainRouter?
    
    fileprivate var titledView: TitledView!
    fileprivate var dataManager: StackViewDataManager! 
    
    @IBOutlet weak var intervalsStackView: UIStackView!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var stackView: UIStackView! {
        didSet {
            dataManager = StackViewDataManager(stackView: stackView)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        walletView.layer.cornerRadius = 20
        walletView.layer.masksToBounds = true
        slider.setThumbImage(#imageLiteral(resourceName: "Thumb"), for: .normal)
        
        titledView = TitledView()
        titledView.title = "Wallet"
        titledView.closePressed = {
            self.dismiss()
        }
        view.addSubview(titledView)
        viewModel.calculateDiference()
    }
    
    override func configure(viewModel: WalletVM) {
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prefillSliderValue()
    }
    
    fileprivate func prefillSliderValue() {
        slider.value = Float(viewModel.selectedInterval.rawValue) / Float(TimeIntervals.count) + 1/14
        updateLabels(selectedInterval: Int(slider.value * Float(TimeIntervals.count)))
    }
    
    // MARK: - Private methods
    fileprivate func show(currencyCart: [CurrencyDifferenceUserCart]) {
        let containers = currencyCart.map { (cart) -> ViewContainer<BalanceDeltaView> in
            let rate = Helper.abbreviateAmount(cart.difference)
            let bal = stringCurrency(from: UInt64(viewModel.balanceForIso(cart.ISO)), localeIso: cart.ISO)
            let isPositive = cart.difference >= 0
            return ViewContainer<BalanceDeltaView>(item: (bal, rate, isPositive))
        }
        
        balanceLabel.text = viewModel.stringBalance
        dataManager.clear().append(containers: containers)
    }
    
    fileprivate func updateLabels(selectedInterval: Int) {
        for (i, view) in intervalsStackView.arrangedSubviews.enumerated() {
            view.alpha = selectedInterval == i ? 1 : 0.5
        }
    }
    
    // MARK: - Actions
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        let image = captureScreen(view: view)
        router?.showProfileView(back: image)
    }
    
    @IBAction func slider(_ sender: UISlider) {
        let selectedInterval = Int(Float(TimeIntervals.count) * sender.value)
        
        guard let interval = TimeIntervals(rawValue: selectedInterval) else {
            return
        }
        
        viewModel.didSelect(interval)
        updateLabels(selectedInterval: selectedInterval)
    }
}

extension WalletViewController: WalletVMDelegate {
    
    func currencyCartDidChanged(_ newCarts: [CurrencyDifferenceUserCart]) {
        show(currencyCart: newCarts)
    }
}
