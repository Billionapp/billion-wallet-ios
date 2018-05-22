//
//  RateProviderFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class RateProviderFactory: RateProviderFactoryProtocol {
    
    private let api: API
    private let rateQ: RateQueueProtocol
    
    init(api: API, rateQ: RateQueueProtocol) {
        self.api = api
        self.rateQ = rateQ
    }
    
    func create() -> RateProviderProtocol {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let storageUrl = documentsDirectory.appendingPathComponent("rate_storage")
        let fileManager = FileManager.default
        let serializer = RateSerializer()
        let fileStorage = FileStorage(saveDir: storageUrl, fileManager: fileManager)
        let rateHistoryStorage = RateHistoryStorage(storage: fileStorage, serializer: serializer)
        let channel = Channel<StorageMessage>()
        // trigger updateAll event to bootstrap history storate timestamps data
        rateHistoryStorage.setChannel(channel)
        fileStorage.setChannel(channel)
        let cachedStorage = RateCachedStorage(storage: rateHistoryStorage)
        let rateProvider = RateProvider(api: api, storage: cachedStorage, rateQueue: rateQ)
        return rateProvider
    }

}
