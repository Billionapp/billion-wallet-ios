//
//  ICloudConfig.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct ICloudConfig {
    
    struct ConfigKeys {
        static let walletDigest = "wallet_digest"
        static let currency = "currencies"
        static let commission = "comission_setting"
        static let userName = "user_name"
        static let version = "version"
    }
    
    let walletDigest: String
    let userName: String
    let currencies: [Currency]
    let feeSize: FeeSize
    let version: String

}

// MARK: - ICloudBackupProtocol

extension ICloudConfig: ICloudBackupProtocol {
    
    static var folder: String? {
        return nil
    }
    
    var destination: String {
        return "config"
    }
    
    var backupJson: [String: Any] {
        let currenciesRaw = currencies.map {$0.code}
    
        return [
            ConfigKeys.walletDigest: walletDigest,
            ConfigKeys.userName: userName,
            ConfigKeys.commission: feeSize.description,
            ConfigKeys.currency: currenciesRaw,
            ConfigKeys.version: Bundle.appVersion
            ]
    }
    
    init(from json: [String: Any], with attachData: Data?) throws {
        
        guard
            let walletDigest = json[ConfigKeys.walletDigest] as? String,
            let feeSizeRaw = json[ConfigKeys.commission] as? String, let feeSize = FeeSize(rawValue: feeSizeRaw.lowercased()),
            let currencyRaw = json[ConfigKeys.currency] as? [String],
            let userName = json[ConfigKeys.userName] as? String,
            let version = json[ConfigKeys.version] as? String else {
            throw ICloud.ICloudError.restoringFromJsonError
        }
        
        self.walletDigest = walletDigest
        self.feeSize = feeSize
        self.currencies = currencyRaw.flatMap { CurrencyFactory.currencyWithCode($0) }
        self.userName = userName
        self.version = version
    }
    
}
