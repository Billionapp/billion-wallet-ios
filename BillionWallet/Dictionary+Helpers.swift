//
//  Dictionary+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

// MARK: - Removing all key-value pairs with nill value

extension Dictionary where Key == String, Value == Any? {
    
    func removeNils() -> [String: Any] {
        var dict = [String: Any]()
        for (key, value) in self {
            if let value = value {
                dict[key] = value
            }
        }
        return dict
    }
}

extension Dictionary {
    
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
    
}
