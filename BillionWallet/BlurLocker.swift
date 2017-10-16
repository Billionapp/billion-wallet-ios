//
//  BlurLocker.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct BlurLocker {
    let window: UIWindow
    
    func addBlur() {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = window.frame
        blurEffectView.tag = 11
        blurEffectView.alpha = 0
        self.window.endEditing(true)
        self.window.addSubview(blurEffectView)
        UIView.animate(withDuration: 0.2) {
            blurEffectView.alpha = 1.0
        }
    }
    
    func removeBlur() {
        guard let view = self.window.viewWithTag(11) else {return}
        showKeyboardIfNeeded()
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0
        }) { _ in
            view.removeFromSuperview()
        }
    }
}

//MARK: - Private methods - 
extension BlurLocker {
    fileprivate func showKeyboardIfNeeded() {
        guard let topVC = UIApplication.topViewController() else {return}
        for subview in topVC.view.subviews {
            if let textField = subview as? UITextField {
                textField.becomeFirstResponder()
            }
        }
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
