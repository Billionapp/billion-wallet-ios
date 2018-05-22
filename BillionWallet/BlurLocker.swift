//
//  BlurLocker.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension UIView {
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for view in subviews {
            if let responder = view.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}

class BlurLocker {
    let window: UIWindow
    weak var blurEffectView: UIView! = nil
    weak var firstResponder: UIResponder? = nil
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func addBlur() {
        let screen = captureScreen(view: window)
        let imageView = UIImageView(frame: window.frame)
        imageView.image = screen
        self.firstResponder = self.window.findFirstResponder()
        self.window.endEditing(true)
        self.window.addSubview(imageView)
        UIView.animate(withDuration: 0.2) {
            imageView.alpha = 1.0
        }
        self.blurEffectView = imageView
    }
    
    func removeBlur() {
        guard let view = blurEffectView else { return }
        firstResponder?.becomeFirstResponder()
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
    }
}
