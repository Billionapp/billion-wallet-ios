//
//  UrlHelper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

private let mainnetTxDetailer = "https://blockchain.info/tx/"
private let testnetTxDetailer = "https://live.blockcypher.com/btc-testnet/tx/"

protocol UrlHelperProtocol {
    func urlForTxhash(hash: String, isTestnet: Bool) -> URL
}

class UrlHelper: UrlHelperProtocol {
    
    init() {
    }
    
    func urlForTxhash(hash: String, isTestnet: Bool) -> URL {
        let prefix = isTestnet ? testnetTxDetailer : mainnetTxDetailer
        let url = String(format: "\(prefix)%@", hash)
        return URL(string: url)!
    }
}
