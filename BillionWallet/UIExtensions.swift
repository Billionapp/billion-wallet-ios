//
//  UIExtensions.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension CALayer {
    func halfHeightCornerRadius() {
        self.cornerRadius = self.frame.size.height/2
    }
    func standardCornerRadius() {
        self.cornerRadius = Layout.model.cornerRadius
        self.masksToBounds = true
    }
}

public extension UIViewController {
    func showPopup(type: PopupType, title: String) {
        let popup = PopupView(type: type, labelString: title)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
}
