//
//  Observer.swift
//  TransactionStorage
//
//  Created by Evolution Group Ltd on 15.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

public struct Identifier: Hashable {
    private let id: String
    
    public init(_ id: String) {
        self.id = id
    }
    
    // MARK: Hashable
    public var hashValue: Int {
        return id.hashValue
    }
    
    public static func ==(_ lhs: Identifier, _ rhs: Identifier) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Identifier: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: String) {
        self.id = value
    }
}

public class Observer<SignalData> {
    public typealias Callback = (SignalData) -> Void
    
    public let id: Identifier
    private let callback: Callback
    
    public init(id: Identifier, callback: @escaping Callback) {
        self.id = id
        self.callback = callback
    }
    
    public func send(_ value: SignalData) {
        self.callback(value)
    }
}

extension Observer: Hashable {
    public var hashValue: Int {
        return self.id.hashValue
    }
    
    public static func ==(_ lhs: Observer, _ rhs: Observer) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension Observer {
    public convenience init(id: String, callback: @escaping Callback) {
        self.init(id: Identifier(id), callback: callback)
    }
}
