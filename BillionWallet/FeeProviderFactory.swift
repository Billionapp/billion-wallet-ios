//
//  FeeProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 31.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol FeeProviderFactory {
    func createFeeProvider() -> FeeProvider
}

class DefaultFeeProviderFactory: FeeProviderFactory {
    private let apiProvider: API
    
    init(apiProvider: API) {
        self.apiProvider = apiProvider
    }
    
    func createFeeProvider() -> FeeProvider {
        let feeFactory = FeeFactory()
        let dirUrl = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory,
                                              in: .userDomainMask).last!
        let url = dirUrl.appendingPathComponent("feecache.json")
        
        let feeCacheStorage = FeeCacheFileStorage(url: url, fileHandler: StandardDataFileHandler())
        let feeCacheService = StandardFeeCacheService(storage: feeCacheStorage)
        
        return FeeProvider(defaultDownloader: BillionFeeDownloader(apiProvider: apiProvider),
                           fallbackDownloader: EarnFeeDownloader(apiProvider: apiProvider),
                           defaultMapper: BillionFeeMapper(factory: feeFactory),
                           fallbackMapper: EarnFeeMapper(factory: feeFactory),
                           filter: StandardFeeFilter(),
                           feeCache: feeCacheService)
    }
}
