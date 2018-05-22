//
//  Dynamic.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class Dynamic<T> {
    typealias Listener = (T) -> ()
    var listener: Listener?
    
    func bind(_ listener: Listener?) {
        self.listener = listener
    }
    
    func bindAndFire(_ listener: Listener?) {
        self.listener = listener
        listener?(value)
    }
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ initialValue: T) {
        value = initialValue
    }
    
    static func &=(_ lhs: Dynamic<T>, _ rhs: T) {
        lhs.value = rhs
    }
}
