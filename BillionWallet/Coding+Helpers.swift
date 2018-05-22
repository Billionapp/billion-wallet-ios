//
//  Coding+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

struct FailableCodableArray<Element : Codable> : Codable {
    
    var elements: [Element]
    
    init(from decoder: Decoder) throws {
        
        var container = try decoder.unkeyedContainer()
        
        var elements = [Element]()
        if let count = container.count {
            elements.reserveCapacity(count)
        }
        
        while !container.isAtEnd {
            if let element = try container
                .decode(FailableDecodable<Element>.self).base {
                
                elements.append(element)
            }
        }
        
        self.elements = elements
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(elements)
    }
}

struct FailableDecodable<Base : Decodable> : Decodable {
    
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}

