//
//  PasscodeViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol PasscodeOutputDelegate: class {
    func didCompleteVerification()
    func didUpdatePasscode(_ passcode: String)
    func didCancelVerification()
}

extension PasscodeOutputDelegate {
    func didUpdatePasscode(_ passcode: String) {}
    func didCancelVerification() {}
}

class PasscodeViewController: BaseViewController<PasscodeVM> {
    
    typealias LocalizedString = Strings.Passcode
    
    @IBOutlet var pinView: PinsView!
    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var router: MainRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinView.maxDots = viewModel.pinSize
        viewCustomization(passcodeCase: viewModel.passcodeCase)
    }
    
    private func localize() {
        cancelButton.setTitle(LocalizedString.cancel, for: .normal)
        deleteButton.setTitle(LocalizedString.delete, for: .normal)
    }
    
    // MARK: - Private methods
    
    private func viewCustomization(passcodeCase: PasscodeCase) {
        titleLabel.text = passcodeCase.title
        subtitleLabel.text = passcodeCase.subtitle
        
        deleteButton.isHidden = true
        
        switch passcodeCase {
        case .lock:
            titleLabel.isHidden = true
            cancelButton.isHidden = false
        case .createFirst:
            titleLabel.isHidden = false
            cancelButton.isHidden = true
        case .createSecond:
            titleLabel.isHidden = false
            cancelButton.isHidden = false
        case .migrateUpdateSecond, .migrate, .migrateUpdateFirst:
            titleLabel.isHidden = false
            cancelButton.isHidden = true
        default:
            titleLabel.isHidden = false
            cancelButton.isHidden = false
            deleteButton.isHidden = true
        }
    }
    
    private func shakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: view.center.x - 10, y: view.center.y)
        animation.toValue = CGPoint(x: view.center.x + 10, y: view.center.y)
        view.layer.add(animation, forKey: "position")
    }
  
    private func showDeleteButton() {
        deleteButton.isHidden = false
        cancelButton.isHidden = true
    }
    
    private func hideDeleteButton() {
        deleteButton.isHidden = true
        switch viewModel.passcodeCase {
        case .createFirst, .migrateUpdateSecond, .migrate, .migrateUpdateFirst:
            cancelButton.isHidden = true
        default:
            cancelButton.isHidden = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        viewModel.pinInput(String(sender.tag))
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        viewModel.backspace()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        viewModel.cancel()
    }
}

// MARK: - PasscodeVMDelegate

extension PasscodeViewController: PasscodeVMDelegate {
    
    func didUpdatePasscodeCase(_ passcodeCase: PasscodeCase) {
        viewCustomization(passcodeCase: passcodeCase)
    }
    
    func didEnterWrongCode() {
        shakeAnimation()
    }
    
    func didFinishVerification() {
        dismiss()
    }
    
    func didCancelVerification() {
        dismiss()
    }
    
    func didUpdate(symbolCount: Int) {
        pinView.filledDots = symbolCount
        showDeleteButton()
    }
    
    func didUpdateMaxDots(_ maxDots: Int) {
        pinView.maxDots = maxDots
    }
    
    func didClearInput() {
        pinView.filledDots = 0
        hideDeleteButton()
    }
}

