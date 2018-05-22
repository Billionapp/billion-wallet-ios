//
//  TouchConveyorView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 25/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

protocol TouchConveyorDelegate: class {
    func touchViewTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchViewTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchViewTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    func touchViewTouchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?)
}

protocol HitTestDelegate: class {
    func test(_ point: CGPoint, with event: UIEvent?) -> Bool
}

class TouchConveyorView: UIView {
    weak var touchDelegate: TouchConveyorDelegate?
    weak var hitDelegate: HitTestDelegate?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.hitDelegate?.test(point, with: event) == true {
            return self
        } else {
            return nil
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchDelegate?.touchViewTouchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchDelegate?.touchViewTouchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchDelegate?.touchViewTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchDelegate?.touchViewTouchesCancelled(touches, with: event)
    }
}


