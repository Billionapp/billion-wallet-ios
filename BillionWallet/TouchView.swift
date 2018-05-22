//
//  TouchLabel.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import AudioToolbox

protocol TouchViewDelegate: class {
    func touchEnded()
}

class TouchView: UIView {
    let gridStep: CGFloat = Layout.model.spacing
    let touchBump: CGFloat = 1.04
    var maxDuration: TimeInterval = 0.6
    
    private weak var delegate: TouchViewDelegate?
    
    func setDelegate(_ delegate: TouchViewDelegate) {
        self.delegate = delegate
    }

    var isForceTouchAvailable: Bool {
        return self.traitCollection.forceTouchCapability == .available
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesBegan(touches, with: event)
        if isForceTouchAvailable {
            UIView.animate(withDuration: 0.07,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseInOut,
                           animations: {

                self.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform(scaleX: self.touchBump, y: self.touchBump)
                }
            }, completion: nil)
        } else {
            let bubbleOffset = CGFloat(5.0)
            let w = (self.frame.width - bubbleOffset)
            let maxScale = ( gridStep / w ) + 1.0
            UIView.animate(withDuration: maxDuration, delay: 0, options: .curveEaseIn, animations: {
                self.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
                }
            }, completion: { success in
                if success {
                    if self == self.hitTest(touches.first!.location(in: self), with: event) {
                        AudioServicesPlaySystemSound(.peek)
                        self.delegate?.touchEnded()
                        self.returnToIdentityAnimatable()
                    }
                }
            })
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        returnToIdentity()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesEnded(touches, with: event)
        self.subviews.forEach { (subview) in
            subview.layer.removeAllAnimations()
            subview.transform = CGAffineTransform(scaleX: self.touchBump, y: self.touchBump)
        }
        self.returnToIdentityAnimatable()
    }
    
    func returnToIdentity() {
        self.subviews.forEach { (subview) in
            subview.transform = CGAffineTransform.identity
        }
    }
    
    func returnToIdentityAnimatable() {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.25,
                       initialSpringVelocity: 5,
                       options: UIViewAnimationOptions.curveEaseOut,
                       animations: {
                        
                        self.subviews.forEach { (subview) in
                            subview.transform = CGAffineTransform.identity
                        }
        }, completion: nil)
    }
}

