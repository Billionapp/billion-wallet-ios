//
//  ChooseFeeViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ChooseFeeViewController: BaseViewController<ChooseFeeVM> {
    
    typealias LocalizedStrings = Strings.ChooseFee
    
    private var titledView: TitledView!
    var conveyorView: TouchConveyorView!
    var behindButton: UIButton?
    
    @IBOutlet private weak var cancelButton: UIButton!
    @IBOutlet private weak var feeSlider: UISlider!
    @IBOutlet private weak var confirmationTimeLabel: UILabel!
    @IBOutlet private weak var feeTotalAmountLabel: UILabel!
    @IBOutlet private weak var feeSatPerByteLabel: UILabel!
    @IBOutlet private weak var confirmationTimeSublabel: UILabel!
    @IBOutlet private weak var feeTotalAmountSublabel: UILabel!
    @IBOutlet weak var notEnoughFundsLabel: UILabel!
    
    weak var mainRouter: MainRouter?
    
    override func configure(viewModel: ChooseFeeVM) {
        viewModel.delegate = self
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConveyor()
        setupTitledView()
        setupSlider()
        configureFeeSlider()
        bindToViewModel()
        localize()
        viewModel.changeSatPerByte(to: Int(feeSlider.value))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSwipeDownGesture()
    }
    
    func bindToViewModel() {
        viewModel.chosenFeeSat.bind { [unowned self] in self.feeSatPerByteLabel.text = $0 }
        viewModel.totalFeeLocal.bind { [unowned self] in self.feeTotalAmountLabel.text = $0 }
        viewModel.estimateTime.bind { [unowned self] in self.confirmationTimeLabel.text = $0 }
    }
    
    private func localize() {
        cancelButton.setTitle(LocalizedStrings.cancel, for: .normal)
    }
    
    private func configureFeeSlider() {
        feeSlider.minimumValue = Float(viewModel.minFee)
        feeSlider.maximumValue = Float(viewModel.maxFee)
        feeSlider.setValue(Float(viewModel.maxFee), animated: false)
        feeSlider.setThumbImage(#imageLiteral(resourceName: "FeeThumb"), for: .normal)
        feeSlider.minimumTrackTintColor = Color.FeeSlider.minimumSliderColor
        feeSlider.maximumTrackTintColor = Color.FeeSlider.maximumSliderColor
    }
    
    private func setupConveyor() {
        guard conveyorView != nil else {
            return
        }
        conveyorView.touchDelegate = self
        conveyorView.hitDelegate = nil
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.subtitle
        view.addSubview(titledView)
        confirmationTimeSublabel.text = LocalizedStrings.confirmationTimeLabel
        feeTotalAmountSublabel.text = LocalizedStrings.feeTotalAmountLabel
    }
    
    private func setupSlider() {
        feeSlider.minimumValue = Float(viewModel.minFee)
        feeSlider.maximumValue = Float(viewModel.maxFee)
        feeSlider.setValue(Float(viewModel.maxFee), animated: false)
        feeSlider.setThumbImage(#imageLiteral(resourceName: "FeeThumb"), for: .normal)
    }
    
    // MARK: Actions
    
    @IBAction func sendAction() {
        viewModel.prepareTransaction()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        viewModel.changeSatPerByte(to: Int(sender.value))
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        navigationController?.pop()
    }
}

extension ChooseFeeViewController: ChooseFeeVMDelegate {
    func setInsufficientFunds(_ flag: Bool) {
        notEnoughFundsLabel.isHidden = !flag
        confirmationTimeLabel.isHidden = flag
        feeTotalAmountLabel.isHidden = flag
        confirmationTimeSublabel.isHidden = flag
        feeTotalAmountSublabel.isHidden = flag
    }
    
    func didCompleteVerification() {
        PopupView.loading.showLoading()
    }
    
    func transactionIsReady(amount: String, amountLocal: String, fee: String, feeLocal: String, total: String, totalLocal: String, contactName: String?) {
        /// Open pin code popup
        let receiver = contactName != nil ? String(format: LocalizedStrings.receiver, contactName!) : ""
        let reason = String(format: LocalizedStrings.reason, receiver, amountLocal, amount, feeLocal, fee, totalLocal, total)
        let sendAmount = String(format: LocalizedStrings.sendAmount, amountLocal)
        mainRouter?.showPasscodeView(passcodeCase: .custom(title: sendAmount, subtitle: "\(amount)"), output: viewModel, reason: reason)
    }
    
    func transactionPublished() {
        PopupView.loading.dismissLoading()
        navigationController?.popToRootViewController(animated: false)
    }
    
    func transactionFailedToPublish(error: Error) {
        PopupView.loading.dismissLoading()
        let popup = PopupView(type: .ok, labelString: String(format: LocalizedStrings.transactionFailedFormat, error.localizedDescription))
        UIApplication.shared.keyWindow?.addSubview(popup)
        navigationController?.popToRootViewController(animated: false)
    }
}

extension ChooseFeeViewController: TouchConveyorDelegate {
    func touchViewTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
    }
    
    func touchViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        let position = touch.location(in: self.view)
        if position.x > feeSlider.frame.origin.x || position.x < feeSlider.frame.origin.x + feeSlider.frame.size.width {
            let range = feeSlider.maximumValue - feeSlider.minimumValue
            let thumbWidth = (feeSlider.currentThumbImage?.size.width)!
            let weightPoint = CGFloat(range) / (feeSlider.frame.size.width - thumbWidth)
            let shift = position.x - feeSlider.frame.origin.x - thumbWidth / 2
            feeSlider.setValue(feeSlider.minimumValue + Float(weightPoint * shift), animated: true)
            viewModel.changeSatPerByte(to: Int(feeSlider.value))
        }
        
        let newBehind = self.view.hitTest(touch.location(in: self.view), with: event)
        
        if newBehind is UIButton {
            let button = newBehind as! UIButton
            if button != behindButton {
                behindButton?.isHighlighted = false
                button.isHighlighted = true
                behindButton = button
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
            } else {
                button.isHighlighted = true
            }
        } else {
            if behindButton != nil {
                behindButton?.isHighlighted = false
                behindButton = nil
                viewModel.tapticService.selectionTaptic(capability:
                    self.traitCollection.forceTouchCapability == .available)
            }
        }
    }
    
    func touchViewTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesEnded(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        let behind = self.view.hitTest(touch.location(in: self.view), with: event)
        if behind is UIButton {
            let button = behind as! UIButton
            button.isHighlighted = false
            button.sendActions(for: .touchUpInside)
        } else {
            feeSlider.sendActions(for: .touchUpInside)
        }
    
        conveyorView.touchDelegate = nil
        conveyorView.removeFromSuperview()
    }
    
    func touchViewTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesCancelled(touches, with: event)
        conveyorView.touchDelegate = nil
        conveyorView.removeFromSuperview()
    }
}
