//
//  DelayedGetureRecognizer.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

protocol DelayedGestureRecognizerDelegate: class {
    func didMove(_ pDiff: CGPoint)
}

class DelayedGestureRecognizer: UIGestureRecognizer {
    weak var delayedDelegate: DelayedGestureRecognizerDelegate?
    private var initialTouchPoint : CGPoint = CGPoint.zero
    private var trackedTouch : UITouch? = nil
    
    func end() {
        self.state = .failed
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if touches.count != 1 {
            self.state = .failed
        }
        
        // Capture the first touch and store some information about it.
        if self.trackedTouch == nil {
            self.trackedTouch = touches.first
            self.initialTouchPoint = (self.trackedTouch?.location(in: nil))!
        } else {
            // Ignore all but the first touch.
            for touch in touches {
                if touch != self.trackedTouch {
                    self.ignore(touch, for: event)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if self.state == .failed {
            return
        }
        
        let newTouch = touches.first
        // There should be only the first touch.
        guard newTouch == self.trackedTouch else {
            self.state = .failed
            return
        }
        let newPoint = (newTouch?.location(in: nil))!
        let x = newPoint.x - initialTouchPoint.x
        let y = newPoint.y - initialTouchPoint.y
        delayedDelegate?.didMove(CGPoint(x: x, y: y))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        let newTouch = touches.first
        let newPoint = (newTouch?.location(in: nil))!
        
        // There should be only the first touch.
        guard newTouch == self.trackedTouch else {
            self.state = .failed
            return
        }
        
        let x = newPoint.x - initialTouchPoint.x
        let y = newPoint.y - initialTouchPoint.y
        delayedDelegate?.didMove(CGPoint(x: x, y: y))
        self.state = .recognized
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.initialTouchPoint = CGPoint.zero
        self.trackedTouch = nil
        self.state = .cancelled
    }
    
    override func reset() {
        super.reset()
        self.initialTouchPoint = CGPoint.zero
        self.trackedTouch = nil
    }
}
