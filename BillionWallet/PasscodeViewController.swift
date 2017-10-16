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
    func didUpdatePascode(_ passcode: String)
}

extension PasscodeOutputDelegate {
    func didUpdatePascode(_ passcode: String) {}
}

class PasscodeViewController: BaseViewController<PasscodeVM> {
    
    @IBOutlet var numberButtons: [UIButton]!
    @IBOutlet var pinImageViews: [UIImageView]!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pinsView: UIView!
    
    weak var router: MainRouter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.verifyWithTouchIdIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewCustomization(passcodeCase: viewModel.passcodeCase)
        viewModel.verifyWithTouchId()
        viewModel.lockDeviceIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(didFinishAutoLayout), object: nil)
        perform(#selector(didFinishAutoLayout), with: nil, afterDelay: 0)
    }
    
    @objc func didFinishAutoLayout() {
        numberButtons.forEach { button in
            button.layer.cornerRadius = button.frame.width / 2
            button.layer.masksToBounds = true
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func viewCustomization(passcodeCase: PasscodeCase) {
        titleLabel.text = passcodeCase.title
        subtitleLabel.text = passcodeCase.subtitle
        
        switch viewModel.passcodeCase {
        case .lock:
            cancelButton.isHidden = true
        case .createFirst:
            cancelButton.isHidden = true
        case .createSecond:
            cancelButton.isHidden = false
        default:
            cancelButton.isHidden = true
        }
    }
    
    fileprivate func animate(sender: UIButton, index: Int) {
        let path = UIBezierPath()
        let pinCenter = pinImageViews[index].center(in: view)
        let buttonCenter = sender.center(in: view)
        
        let circle = CircleView(frame: sender.bounds)
        circle.style = .light
        view.addSubview(circle)
        
        path.move(to: buttonCenter)
        let cp = CGPoint(x: pinCenter.x, y: buttonCenter.y)
        path.addCurve(to: CGPoint(x:pinCenter.x, y:pinCenter.y), controlPoint1: cp, controlPoint2: pinCenter)
        
        let positionAnim = CAKeyframeAnimation(keyPath: "position")
        positionAnim.path = path.cgPath
        positionAnim.calculationMode = kCAAnimationLinear
        
        circle.layer.position = pinCenter
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.fromValue = NSNumber(value: 0)
        fadeAnim.toValue = NSNumber(value: 1)
        circle.layer.opacity = 1.0
        
        let scale = pinImageViews[0].bounds.width / sender.bounds.width
        let scaleAnim = CABasicAnimation(keyPath: "transform")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(scale, scale, 1))
        circle.layer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
        
        let group = CAHandledGroupAnimation()
        group.completionHandler = {
            self.viewModel.pin += String(sender.tag)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                circle.removeFromSuperview()
            })
        } as (() -> Void)
        
        group.animations = [scaleAnim, positionAnim, fadeAnim]
        group.duration = 0.4
        group.isRemovedOnCompletion = true
        circle.layer.add(group, forKey: "fly")
    }
    
    func shakeAnimation() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.06
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: view.center.x - 10, y: view.center.y)
        animation.toValue = CGPoint(x: view.center.x + 10, y: view.center.y)
        view.layer.add(animation, forKey: "position")
    }
    
    // MARK: - Actions
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        if viewModel.pin.characters.count < 4 {
            viewModel.pin += String(sender.tag)
        }
    }
    
    @IBAction func deletePressed(_ sender: UIButton) {
        viewModel.clearPin()
    }
    
    @IBAction func cancelPressed(_ sender: UIButton) {
        switch viewModel.passcodeCase {
        case .createSecond:
            viewModel.passcodeCase = .createFirst
        default:
            dismiss()
        }
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
    
    func didUpdatePin() {
        for (i, imageView) in pinImageViews.enumerated() {
            imageView.isHighlighted = i < viewModel.pin.characters.count
        }
    }
    
}

