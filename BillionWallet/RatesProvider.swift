//
//  RatesProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18.09.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class RatesProvider {
    weak var apiProvider: API?
    weak var walletProvider: WalletProvider?
    private var timer: Timer?
    var ratesCash = [Rate]()
    var ratesHistory = [RateHistory]()
    let fileManager = FileManager.default
    let localRatesURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory , in: .userDomainMask).last!
    
    init(apiProvider: API, walletProvider: WalletProvider) {
        self.apiProvider = apiProvider
        self.walletProvider = walletProvider
        checkRateHistory()
    }
    
    func ratesForTx(transaction: BRTransaction) -> [Rate] {
        let history = ratesHistory.filter({ $0.txts == Int64(transaction.timestamp + NSTimeIntervalSince1970) })
        if let rateForTx = history.first {
            return rateForTx.rates
        } else {
            return ratesCash
        }
    }
    
    func checkRateHistory() {
        if let wallet = walletProvider?.manager.wallet {
            checkRateHistoryForTxs(transactions: wallet.allTransactions as! [BRTransaction])
        }
    }
    
    func startTimer() {
        Logger.info("Rates timer is fired")
        apiProvider?.getCurrenciesRate(completion: {[weak self] (result) in
            switch result {
            case .success(let rates):
                self?.ratesCash = rates
                Logger.info("Success download rates. Rates updated")
                return
            case .failure(_):
                Logger.error("Download rates error")
                return
            }
        })
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(getRate), userInfo: nil, repeats: true)
    }
    
    @objc func getRate() {
        apiProvider?.getCurrenciesRate(completion: {[weak self] (result) in
            switch result {
            case .success(let rates):
                self?.ratesCash = rates
                Logger.info("Success download rates. Rates updated")
                return
            case .failure(let error):
                Logger.error("Download rates error: \(error.localizedDescription)")
                return
            }
        })
    }
    
    func getRateHistory(tx: BRTransaction) {
        apiProvider?.getCurrenciesRateHistory(from: tx, completion: {[weak self] (result) in
            switch result {
            case .success(let rates):
                guard let tuple = self?.infoFromTx(tx: tx) else { return }
                let rateHistory = RateHistory(txts: Int64(tx.timestamp+NSTimeIntervalSince1970), rates: rates, isReceivedTx: tuple.isReceived, amount: tuple.amount)
                try? rateHistory.save()
                self?.ratesHistory.append(rateHistory)
                Logger.info("Success download rates history.")
                return
            case .failure(let error):
                Logger.error("Download rates history error: \(error.localizedDescription)")
                return
            }
        })
    }
    
    func checkRateHistoryForTxs(transactions: [BRTransaction]) {
        transactions.forEach { (transaction) in
            let txTimestamp = String(format:"%.0f", (transaction.timestamp+NSTimeIntervalSince1970))
            let url = localRatesURL.appendingPathComponent("\(txTimestamp).json")
            guard let _ = NSData(contentsOf: url) else {
                if let existCash = ratesCash.first,
                    let intStamp = Int64(txTimestamp) {
                    let difference = existCash.rateTimestamp - intStamp
                    if abs(difference) < 600 {
                        let tuple = self.infoFromTx(tx: transaction)
                        let rateHistory = RateHistory(txts: Int64(transaction.timestamp+NSTimeIntervalSince1970), rates: ratesCash, isReceivedTx: tuple.isReceived, amount: tuple.amount)
                        try? rateHistory.save()
                        self.ratesHistory.append(rateHistory)
                    }
                }
                getRateHistory( tx:transaction )
                return
            }
            let historyItem = RateHistory(fromTxTimestamp: txTimestamp)
            self.ratesHistory.append(historyItem)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        Logger.info("Rates timer stopped")
    }
    
    func isFired() -> Bool {
        guard let t = timer else {return false}
        return t.isValid
    }
    
    func fireTimer() {
        timer?.fire()
    }
    
    func infoFromTx(tx: BRTransaction) -> (isReceived: Bool, amount: Int64) {
        let sent = walletProvider?.manager.wallet?.amountSent(by: tx) ?? 0
        let received = walletProvider?.manager.wallet?.amountReceived(from: tx) ?? 0
        let isReceived = !(sent > 0)
        var amount:Int64
        if isReceived {
            amount = Int64(received)
        } else {
            amount = Int64(received) - Int64(sent)
        }
        return (isReceived, amount)
    }
}

extension RatesProvider: RatesSource {
    func rateForCurrency(_ currency: Currency) -> Rate? {
        return ratesCash.first { $0.currencyCode == currency.code }
    }
}
