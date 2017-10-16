//
//  Animator.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10.10.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toVC = transitionContext.viewController(forKey: .to)
        let fromVC = transitionContext.viewController(forKey: .from)
        
        transitionContext.containerView.addSubview((toVC?.view)!)
        toVC!.view.alpha = 0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toVC!.view.alpha = 1
            fromVC!.view.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }) { (finished) in
            fromVC!.view.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}

