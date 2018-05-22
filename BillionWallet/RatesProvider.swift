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
    private weak var walletProvider: WalletProvider!
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
    
    func ratesForTx(transaction: Transaction) -> [Rate] {
        return getRatesFor(time: transaction.timestamp)
    }
    
    func getRatesFor(time: TimeInterval) -> [Rate] {
        let history = ratesHistory.filter({ $0.txts == Int64(time + NSTimeIntervalSince1970) })
        if let rateForTx = history.first {
            return rateForTx.rates
        } else {
            return ratesCash
        }
    }
    
    func checkRateHistory() {
        // FIXME: try to remove wallet from dependencies in rates provider
        guard let wallet = try? walletProvider.getWallet() else {
            return
        }
        let allTx = wallet.allTransactions.map({ Transaction(brTransaction: $0, walletProvider: walletProvider) })
        checkRateHistoryForTxs(transactions: allTx)
    }
    
    func startTimer() {
        Logger.info("Rates timer is fired")
        getRate()
        timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(getRate), userInfo: nil, repeats: true)
    }
    
    @objc func getRate() {
        let callback: (Result<[Rate]>) -> Void = { [weak self] (result) in
            switch result {
            case .success(let rates):
                self?.ratesCash = rates
                Logger.info("Success download rates. Rates updated")
            case .failure(let error):
                if let lastHistory = self?.ratesHistory.first {
                    self?.ratesCash = lastHistory.rates
                } else {
                    //FIXME: Hardcoded rates
                    self?.ratesCash = [Rate.init(currencyCode: "USD", btc: 12349.58, timestamp: 1516118276),
                                       Rate.init(currencyCode: "HKD", btc: 96615.086693000005, timestamp: 1516118276),
                                       Rate.init(currencyCode: "CNY", btc: 79564.639066000003, timestamp: 1516118276)]
                }
                Logger.error("Download rates error: \(error.localizedDescription)")
            }
            NotificationCenter.default.post(name: .walletBalanceChangedNotificationName,
                                            object: nil)
        }
        
        apiProvider?.getCurrenciesRate(completion: { [weak self] result in
            switch result {
            case .success:
                callback(result)
            case .failure(let error):
                Logger.warn("Rates request failed, retring with fallback. Reason: \(error.localizedDescription)")
                self?.apiProvider?.getCurrenciesRateFallback(completion: callback)
            }
        })
    }
    
    func getRateHistory(tx: Transaction) {
        apiProvider?.getCurrenciesRateHistory(from: tx, completion: {[weak self] (result) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let rates):
                guard let tuple = try? strongSelf.infoFromTx(tx: tx) else { return }
                let rateHistory = RateHistory(txts: Int64(tx.timestamp+NSTimeIntervalSince1970), rates: rates, isReceivedTx: tuple.isReceived, amount: tuple.amount)
                try? rateHistory.save()
                strongSelf.ratesHistory.append(rateHistory)
                Logger.info("Success download rates history.")
                return
            case .failure(let error):
                Logger.error("Download rates history error: \(error.localizedDescription)")
                return
            }
        })
    }
    
    func checkRateHistoryForTxs(transactions: [Transaction]) {
        transactions.forEach { (transaction) in
            let txTimestamp = String(format:"%.0f", (transaction.timestamp+NSTimeIntervalSince1970))
            let url = localRatesURL.appendingPathComponent("\(txTimestamp).json")
            guard let _ = NSData(contentsOf: url) else {
                if let existCash = ratesCash.first,
                    let intStamp = Int64(txTimestamp) {
                    let difference = existCash.rateTimestamp - intStamp
                    if abs(difference) < 600 {
                        
                        do {
                            let tuple = try self.infoFromTx(tx: transaction)
                            let rateHistory = RateHistory(txts: Int64(transaction.timestamp+NSTimeIntervalSince1970), rates: ratesCash, isReceivedTx: tuple.isReceived, amount: tuple.amount)
                            try? rateHistory.save()
                            self.ratesHistory.append(rateHistory)
                        } catch let error {
                            Logger.warn("\(error.localizedDescription)")
                            return
                        }
                    }
                }
                getRateHistory(tx: transaction)
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
    
    private func infoFromTx(tx: Transaction) throws -> (isReceived: Bool, amount: Int64) {
        let wallet = try walletProvider.getWallet()
        let sent = wallet.amountSent(by: tx.brTransaction)
        let received = wallet.amountReceived(from: tx.brTransaction)
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
