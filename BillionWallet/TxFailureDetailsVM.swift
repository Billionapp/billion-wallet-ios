//
//  TxFailureDetailsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 22/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation


class TxFailureDetailsVM {

    private let failureTransactionProvider: FailureTxProtocol
    private var rates: [Rate]?
    private let historicalFiatConverter: FiatConverter
    private let currentFiatConverter: FiatConverter
    let cellY: CGFloat
    let walletProvider: WalletProvider
    
    let displayer: FailureTxDisplayer
    
    init(displayer: FailureTxDisplayer,
         failureTransactionProvider: FailureTxProtocol,
         walletProvider: WalletProvider,
         ratesProvider: RateProviderProtocol,
         defaults: Defaults,
         cellY: CGFloat) {
        
        self.failureTransactionProvider = failureTransactionProvider
        self.walletProvider = walletProvider
        self.displayer = displayer
        self.cellY = cellY
        
        let source = HistoricalRatesSource(ratesProvider: ratesProvider)
        if let timeInterval = TimeInterval(displayer.failureTx.identifier) {
            source.set(time: timeInterval)
        }
        historicalFiatConverter = FiatConverter(currency: defaults.currencies.first!, ratesSource: source)
        let ratesSource = DefaultRateSource(rateProvider: ratesProvider)
        currentFiatConverter = FiatConverter(currency: defaults.currencies.first!, ratesSource: ratesSource)
    }
    
    var localCurrencyAmount: String {
        return historicalFiatConverter.fiatStringForBtcValue(displayer.failureTx.amount)
    }
    
    var localCurrencyAmountNow: String {
        return currentFiatConverter.fiatStringForBtcValue(displayer.failureTx.amount)
    }
    
    var localFeeAmount: String {
        return currentFiatConverter.fiatStringForBtcValue(displayer.failureTx.fee)
    }
    
    var satoshiAmount: String {
        return Satoshi.amount(UInt64(displayer.failureTx.amount))
    }
    
    func deleteTransaction() {
        failureTransactionProvider.deleteFailureTx(identifier: displayer.failureTx.identifier, completion: {
            Logger.info("Failure transaction deleted")
        }) { error in
            Logger.error("Failure transaction deletion failed")
        }
    }

}
