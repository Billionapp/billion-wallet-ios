//
//  TouchLabel.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import AudioToolbox

protocol TouchButtonViewDelegate: class {
    func touchEnded(_ sender: UIView)
}

class TouchButtonView: UIView {
    var touchBump: CGFloat {
        return (Layout.model.spacing + self.frame.size.width - 10) / self.frame.size.width
    }
    var maxDuration: TimeInterval = 0.6
    
    private weak var delegate: TouchButtonViewDelegate?
    
    func setDelegate(_ delegate: TouchButtonViewDelegate) {
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
            let maxScale = ( Layout.model.spacing / self.frame.width ) + 1
            UIView.animate(withDuration: maxDuration, delay: 0, options: .curveEaseIn, animations: {
                self.subviews.forEach { (subview) in
                    subview.transform = CGAffineTransform(scaleX: maxScale, y: maxScale)
                }
            }, completion: { success in
                if success {
                    AudioServicesPlaySystemSound(.peek)
                    self.delegate?.touchEnded(self)
                    self.returnToIdentityAnimatable()
                }
            })
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        if isForceTouchAvailable {
            let w = self.frame.width
            let normalizedProgress = touch.force * ( Layout.model.spacing / w ) + touchBump
            
            self.subviews.forEach { (subview) in
                subview.transform = CGAffineTransform(scaleX: normalizedProgress, y: normalizedProgress)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super .touchesCancelled(touches, with: event)
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
