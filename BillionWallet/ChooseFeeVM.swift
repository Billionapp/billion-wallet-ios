//
//  ChooseFeeVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol ChooseFeeVMDelegate: class {
    func transactionIsReady(amount: String, amountLocal: String, fee: String, feeLocal: String, total: String, totalLocal: String, contactName: String?)
    func transactionFailedToPublish(error: Error)
    func transactionPublished()
    func didCompleteVerification()
    func setInsufficientFunds(_ flag: Bool)
}

class ChooseFeeVM {
    typealias LocalizedStrings = Strings.ChooseFee
    
    weak var delegate: ChooseFeeVMDelegate?
    
    private let sendTransactionProvider: SendTransactionProvider
    private let noteProvider: TransactionNotesProvider
    let tapticService: TapticService
    private let btcFormatter: NumberFormatter
    private let currency: Currency
    private let fiatConverter: FiatConverter
    private let confirmTimeFormatter: MinutesFormatter
    private let contactsProvider: ContactsProvider
    
    var amount: UInt64
    var chosenSatPerByte: Int
    var contact: ContactProtocol?
    var userNote: String?
    private var fees: [FeeEstimate]
    private var txs: [Transaction]
    
    let estimateTime: Dynamic<String>
    let totalFeeSat: Dynamic<String>
    let totalFeeLocal: Dynamic<String>
    let chosenFeeSat: Dynamic<String>
    
    init(sendTransactionProvider: SendTransactionProvider,
         defaultsProvider: Defaults,
         ratesProvider: RateProviderProtocol,
         noteProvider: TransactionNotesProvider,
         confirmTimeFormatter: MinutesFormatter,
         tapticService: TapticService,
         contactsProvider: ContactsProvider
         ) {
        
        self.contactsProvider = contactsProvider
        self.sendTransactionProvider = sendTransactionProvider
        self.tapticService = tapticService
        txs = []
        fees = sendTransactionProvider.feeProvider.feeEstimates
        self.noteProvider = noteProvider
        self.amount = 0
        self.chosenSatPerByte = fees.last!.maxFee
        
        self.currency = defaultsProvider.currencies.first!
        let rateSource = DefaultRateSource(rateProvider: ratesProvider)
        self.fiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
        self.btcFormatter = Satoshi.formatter
        self.confirmTimeFormatter = confirmTimeFormatter
        
        self.estimateTime = Dynamic("")
        self.totalFeeSat = Dynamic("")
        self.totalFeeLocal = Dynamic("")
        self.chosenFeeSat = Dynamic("")
    }
    
    var minFee: Int {
        return fees.first!.minFee
    }
    
    var maxFee: Int {
        return fees.last!.maxFee
    }
    
    private func checkFunds( with amount: UInt64) {
        let isInsufficient = amount == 0 ? true : false
        delegate?.setInsufficientFunds(isInsufficient)
    }
    
    func changeSatPerByte(to value: Int) {
        chosenSatPerByte = value
        if let fee = fees.first(where: { $0.minFee <= value && $0.maxFee >= value }) {
            estimateTime &= confirmTimeFormatter.stringForMinutes(fee.avgTime)
        }
    
        chosenFeeSat &= String(format: LocalizedStrings.feeSatPerByteFormat, btcFormatter.string(for: chosenSatPerByte) ?? "NaN")
        let totalFee = sendTransactionProvider.totalFeeForAmount(amount, feeRate: UInt64(value))
        checkFunds(with: totalFee)
        
        totalFeeSat &= btcFormatter.string(for: totalFee) ?? "NaN"
        totalFeeLocal &= fiatConverter.fiatStringForBtcValue(totalFee)
    }
    
    func prepareTransaction() {
        do {
            let txInfo = try sendTransactionProvider.prepareTransactions(amount, feeRate: UInt64(chosenSatPerByte))
            self.txs = txInfo.txs
            let totalAmount = txInfo.totalAmount
            let totalFee = txInfo.totalFee
            let amountTotalSat = btcFormatter.string(from: NSNumber(value: totalAmount))!
            let amountTotalLocal = fiatConverter.fiatStringForBtcValue(totalAmount)
            let feeTotalSat = btcFormatter.string(from: NSNumber(value: totalFee))!
            let feeTotalLocal = fiatConverter.fiatStringForBtcValue(totalFee)
            let amountFullSat = btcFormatter.string(from: NSNumber(value: totalAmount + totalFee))!
            let amountFullLocal = fiatConverter.fiatStringForBtcValue(totalAmount + totalFee)
            Logger.info("Transactions are ready for publish: \(txs)")
            delegate?.transactionIsReady(amount: amountTotalSat,
                                         amountLocal: amountTotalLocal,
                                         fee: feeTotalSat,
                                         feeLocal: feeTotalLocal,
                                         total: amountFullSat,
                                         totalLocal: amountFullLocal,
                                         contactName: contact?.givenName)
            
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
    
    func publishTransactions() {
        guard let _ = txs.first else {
            let description = LocalizedStrings.transactionFailedFormat
            let error = NSError(domain: "Billion", code: -1, userInfo: [NSLocalizedDescriptionKey:description])
            self.delegate?.transactionFailedToPublish(error: error)
            return
        }
        
        sendTransactionProvider.registerForPublish(txs, success: {
            self.sendTransactionProvider.runSuccessPostPublishTasks(for: self.txs)
            self.setUserNote(for: [self.txs.last!])
            if var contact = self.contact {
                self.contactsProvider.updateLastUsed(contact: &contact)
            }
            self.delegate?.transactionPublished()
        }, failure: { (error) in
            // NOTE: Set failure for last only, without NTX
            if let tx = self.txs.last {
                self.sendTransactionProvider.runFailurePostPublishTasks(for: [tx])
            }
            self.delegate?.transactionFailedToPublish(error: error)
        })
    }
    
    fileprivate func setUserNote(for transactions: [Transaction]) {
        guard let userNote = self.userNote else { return }
        
        for transaction in transactions {
            self.noteProvider.setUserNote(with: userNote, for: transaction.txHash)
        }
    }
}

extension ChooseFeeVM: PasscodeOutputDelegate {
    func didCompleteVerification() {
        delegate?.didCompleteVerification()
        publishTransactions()
    }
}
