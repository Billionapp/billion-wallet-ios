//
//  ImageCacheProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31/07/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ImageCacheProvider: ImageCache {
    // MARK: - Private
    fileprivate var cache = [String: UIImage]()
    fileprivate let network: Network
    
    // MARK: - Lifecycle
    required init(network: Network) {
        self.network = network
    }
    
    // MARK: - Public
    func image(url: String, success: @escaping (UIImage) -> Void, failure: @escaping (Error) -> Void) -> NetworkCancelable? {
        if let existing = self.cache[url] {
            success(existing)
            print("cached")
            return nil
        }
        
        let request = NetworkRequest(method: .GET, baseUrl: "", path: url)
        return self.network.makeRequest(
            request) { [weak self] (result: Result<Data>) in
                guard let `self` = self else { return }
                
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        failure(ImageCacheError.invalidResponse)
                        return
                    }
                    self.cache[url] = image
                    success(image)
                    
                case .failure(let error):
                    failure(error)
                }
            }
    }
    func hasImageFor(_ url: String) -> Bool {
        return (self.cache[url] != nil)
    }
    func cachedImage(url: String, or: UIImage?) -> UIImage? {
        return self.cache[url] ?? or
    }
    func clearCache() { self.cache = [String: UIImage]() }
}
