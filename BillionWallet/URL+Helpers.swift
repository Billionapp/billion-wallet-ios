//
//  URL+Helpers.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension URL {
    
    func find(contains: String) -> URL? {
        let directoryContents = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [])
        return directoryContents?.filter { $0.absoluteString.contains(contains) }.first
    }
    
    func isDirectory() -> Bool {
        return pathExtension.isEmpty
    }
    
}
