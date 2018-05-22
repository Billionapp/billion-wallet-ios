//
//  BillionFeeDownloader.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class BillionFeeDownloader: FeeDownloader {
    private weak var apiProvider: API?
    
    init(apiProvider: API) {
        self.apiProvider = apiProvider
    }
    
    func downloadFee(_ completion: @escaping (JSON) -> Void, failure: @escaping (Error) -> Void) {
        guard let apiProvider = apiProvider else {
            failure(NSError(domain: "Billion", code: -1000, userInfo: nil))
            return
        }
        apiProvider.getFee(failure: failure, completion: completion)
    }
}
