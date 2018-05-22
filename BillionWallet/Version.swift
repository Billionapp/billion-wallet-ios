//
//  Version.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// String version, representable in form major.minor.bugfix
struct Version: ExpressibleByStringLiteral, RawRepresentable, Equatable {
    typealias RawValue = String
    typealias StringLiteralType = String
    
    var rawValue: String {
        return "\(major).\(minor).\(bugfix)"
    }
    
    var major: String
    var minor: String
    var bugfix: String
    
    init(_ major: String, _ minor: String = "0", _ bugfix: String = "0") {
        self.major = major
        self.minor = minor
        self.bugfix = bugfix
    }
    
    init(_ major: Int, _ minor: Int = 0, _ bugfix: Int = 0) {
        self.major = "\(major)"
        self.minor = "\(minor)"
        self.bugfix = "\(bugfix)"
    }
    
    init(stringLiteral value: Version.StringLiteralType) {
        let parts = value.split(separator: ".", omittingEmptySubsequences: true)
        major = (parts.count < 1) ? "0" : String(parts[0])
        minor = (parts.count < 2) ? "0" : String(parts[1])
        bugfix = (parts.count < 3) ? "0" : String(parts[2])
    }
    
    init?(rawValue: Version.RawValue) {
        self.init(stringLiteral: rawValue)
    }
}

extension Version: Comparable {
    static func <(lhs: Version, rhs: Version) -> Bool {
        let l1 = Int(lhs.major) ?? 0
        let l2 = Int(lhs.minor) ?? 0
        let l3 = Double(lhs.bugfix) ?? 0.0
        
        let r1 = Int(rhs.major) ?? 0
        let r2 = Int(rhs.minor) ?? 0
        let r3 = Double(rhs.bugfix) ?? 0.0
        
        if l1 > r1 {
            return false
        }
        if l1 == r1 && l2 > r2 {
            return false
        }
        if l1 == r1 && l2 == r2 && l3 > r3 {
            return false
        }
        return true
    }
}
