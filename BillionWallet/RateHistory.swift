//
//  Rate_Storable.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

/// A rate point in history
struct RateHistory: Codable {
    /// Transaction timestamp
    let txts: Int64
    /// Rates, valid for the moment `txts`
    let rates: [Rate]
    /// True if transaction is incoming
    let isReceivedTx: Bool
    /// Satoshi value of transaction
    let amount: Int64
    
    init(txts: Int64, rates: [Rate], isReceivedTx: Bool, amount: Int64) {
        self.txts = txts
        self.rates = rates
        self.isReceivedTx = isReceivedTx
        self.amount = amount
    }
    
    init(fromTxTimestamp:String) {
        let localRatesURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory , in: .userDomainMask).last!
        let url = localRatesURL.appendingPathComponent("\(fromTxTimestamp).json")
        let jsonString = try? String(contentsOf: url)
        let data = jsonString?.data(using: .utf8)
        let object = try! JSONDecoder().decode(RateHistory.self, from: data!)
        self.txts = object.txts
        self.rates = object.rates
        self.isReceivedTx = object.isReceivedTx
        self.amount = object.amount
    }
    
    func save() throws {
        let fileManager = FileManager.default
        let localRatesURL = fileManager.urls(for: FileManager.SearchPathDirectory.documentDirectory , in: .userDomainMask).last!
        let url = localRatesURL.appendingPathComponent("\(txts).json")
        let jsonData = try JSONEncoder().encode(self)
        let string = String(data: jsonData, encoding: .utf8)
        if fileManager.fileExists(atPath: url.absoluteString) {
            try fileManager.removeItem(at: url)
            try string?.write(to: url, atomically: false, encoding: .utf8)
        } else {
            try string?.write(to: url, atomically: false, encoding: .utf8)
        }
    }
}
