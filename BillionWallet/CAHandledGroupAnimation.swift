//
//  CAHandledGroupAnimation.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class CAHandledGroupAnimation: CAAnimationGroup, CAAnimationDelegate {
    var completionHandler: (() -> Void)? {
        didSet {
            if completionHandler != nil {
                delegate = self
            } else {
                delegate = nil
            }
        }
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completionHandler?()
    }
}
