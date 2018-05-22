//
//  Channel.swift
//  TransactionStorage
//
//  Created by Evolution Group Ltd on 15.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

public class Channel<SignalData> {
    private var observers: Set<Observer<SignalData>>
    
    public init() {
        observers = Set<Observer<SignalData>>()
    }
    
    public func addObserver(_ observer: Observer<SignalData>) {
        if observers.contains(observer) {
            observers.remove(observer)
            observers.insert(observer)
        } else {
            observers.insert(observer)
        }
    }
    
    public func removeObserver(withId observerId: Identifier) {
        if let observer = observers.first(where: { $0.id == observerId }) {
            removeObserver(observer)
        }
    }
    
    public func removeObserver(_ observer: Observer<SignalData>) {
        _ = observers.remove(observer)
    }
    
    public func send(_ value: SignalData) {
        for observer in observers {
            observer.send(value)
        }
    }
}

extension Channel {
    public func removeObserver(withId observerId: String) {
        self.removeObserver(withId: Identifier(observerId))
    }
}
