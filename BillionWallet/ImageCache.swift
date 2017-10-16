//
//  ImageCache.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

enum ImageCacheError: Error, CustomStringConvertible {
    case invalidResponse
    
    var description: String {
        switch self {
        case .invalidResponse: return "Received an invalid response"
        }
    }
}

protocol ImageCache {
    init(network: Network)
    
    func image(url: String, success: @escaping (UIImage) -> Void, failure: @escaping (Error) -> Void) -> NetworkCancelable?
    func hasImageFor(_ url: String) -> Bool
    func cachedImage(url: String, or: UIImage?) -> UIImage?
    func clearCache()
}
