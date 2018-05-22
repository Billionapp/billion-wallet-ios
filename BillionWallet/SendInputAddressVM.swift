//
//  SendInputAddressVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SendInputAddressVM {
    typealias LocalizedStrings = Strings.SendInput
    
    private let maxSendAmountBuilder: MaxSendAmountBuilder
    private weak var wallet: BWallet!
    weak var walletProvider: WalletProvider!
    let tapticService: TapticService
    private let fiatConverter: FiatConverter
    private let btcFormatter: NumberFormatter
    private let currency: Currency
    private(set) var amount: UInt64 {
        didSet {
            amountDidSet()
        }
    }
    private var currencyInputState: CurrencyButtonState
    private var maxSendAmount: MaxSendAmount
    private var roundedSatoshi: String?
    private var tempLocalAmount: Double = 0
    
    var delegate: SendInputVMDelegate?

    let receiverImageRepr: UIImage
    let title: Dynamic<String>
    let subtitle: String
    let inputAmountPrefix: Dynamic<String>
    let amountLabel: Dynamic<String>
    let paymentRequest: PaymentRequest
    var userPaymentRequest: UserPaymentRequest?
    var failureTransaction: FailureTx?
    var inputfield = TextInputField()

    init(maxSendAmountBuilder: MaxSendAmountBuilder,
         paymentRequest: PaymentRequest,
         ratesProvider: RateProviderProtocol,
         defaultsProvider: Defaults,
         tapticService: TapticService,
         walletProvider: WalletProvider) {
        
        self.maxSendAmountBuilder = maxSendAmountBuilder
        self.paymentRequest = paymentRequest
        self.currency = defaultsProvider.currencies.first!
        self.btcFormatter = Satoshi.formatter
        self.tapticService = tapticService
        self.walletProvider = walletProvider
        
        self.currencyInputState = .localCurrency
        let rateSource = DefaultRateSource(rateProvider: ratesProvider)
        self.fiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
        self.maxSendAmount = maxSendAmountBuilder.zeroMaxSendAmount()
        self.amount = paymentRequest.amount
        self.receiverImageRepr =  #imageLiteral(resourceName: "QRIcon")
        
        self.inputAmountPrefix = Dynamic(currency.symbol)
        self.title = Dynamic(LocalizedStrings.title)
        self.subtitle = paymentRequest.address
        self.amountLabel = Dynamic("")
        
        subscribeToNotifications()
        calculateMaxSendAmount()
        amountDidSet()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var receiverAddress: String {
        return paymentRequest.address
    }
    
    var isSynced: Bool {
        return walletProvider.syncProgress == 1.0
    }
    
    func checkInputMode() {
        if inputfield.commentInput {
            delegate?.switchInputToCommentMode()
        }
    }
    
    func prefillAmountForFailureTransaction() {
        if let failureTransaction = failureTransaction {
            amount = UInt64(failureTransaction.amount)
            delegate?.didRecognizeFailureTransaction()
        }
    }
    
    func prefillAmountForUserPaymentRequest() {
        if let userPaymentRequest = userPaymentRequest {
            amount = UInt64(userPaymentRequest.amount)
            delegate?.didRecognizePaymentRequest()
        }
    }
    
    func prefillAmountForPaymentRequest() {
        if paymentRequest.amount > 0 {
            amount = paymentRequest.amount
            delegate?.didRecognizePaymentRequest()
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.calculateMaxSendAmount), name: .walletBalanceChangedNotificationName, object: nil)
    }
    
    @objc
    private func calculateMaxSendAmount() {
        do {
            maxSendAmount = try maxSendAmountBuilder.buildMaxSendAmount()
            verifyAmount()
        } catch let error {
            Logger.error("Cannot calculate max send amount: \(error.localizedDescription)")
        }
    }
    
    private func amountStringToDecimal(_ amountString: String) -> Decimal {
        // Here we can opt logic regarding amount string formatting
        // i.e. parse amount string through formatter
        return Decimal(string: amountString) ?? Decimal(0)
    }
    
    private func verifyAmount() {
        if amount <= maxSendAmount.minimumAmount {
            delegate?.didEnterLowAmount()
        } else if amount <= maxSendAmount.safeMaxAmount {
            delegate?.didEnterSafeInput()
        } else if amount <= maxSendAmount.unsafeMaxAmount {
            delegate?.didEnterUnsafeInput()
        } else {
            delegate?.didOverflow()
        }
    }
    
    func changeCurrencyInputState(_ state: CurrencyButtonState) {
        currencyInputState = state
    }
    
    func amountDidSet() {
        if amount == 0 {
            title &= LocalizedStrings.title
        } else {
            let localAmountString = fiatConverter.fiatStringForBtcValue(amount)
            title &= String(format: LocalizedStrings.titleAmountFormat, localAmountString)
            if currencyInputState == .localCurrency {
                amountLabel &= localAmountString
            } else {
                amountLabel &= btcFormatter.string(for: amount) ?? ""
            }
        }
        verifyAmount()
    }
    
    func changeCurrencyState(_ currencyState: CurrencyButtonState) {
        currencyInputState = currencyState
        inputAmountPrefix &= (currencyState == .satoshi) ? Strings.satoshiSymbol : currency.symbol
    }
    
    func changeAmountString(_ amountString: String) {
        switch currencyInputState {
        case .satoshi:
            amount = UInt64(amountString) ?? 0
            if amountString == "0" {
                delegate?.deleteLastSymbol()
                return
            }
            
            checkStringForComma(text: amountString)
        case .localCurrency:
            if isRedundantFractionDigits(amount: amountString) {
                delegate?.deleteLastSymbol()
                return
            }
            
            tempLocalAmount = Double(amountString) ?? 0
            let value = amountStringToDecimal(amountString)
            amount = fiatConverter.convertToBtc(fiatValue: value)
        }
    }
    
    func isSyncingNow() -> Bool {
        // FIXME: Do we really need this?
        return false
    }
    
    private func isRedundantFractionDigits(amount: String) -> Bool {
        let separator = Locale.current.decimalSeparator ?? "."
        guard let commaIndex = amount.index(of: Array(separator).first!) else { return false }
        let decimalPartIndex = amount.index(after: commaIndex)
        let decimalPartString = amount[decimalPartIndex...]
        
        if decimalPartString.count > currency.fractionDigits { return true}
        return false
    }
    
    private func checkStringForComma(text: String) {
        var str = text
        let separator = Locale.current.decimalSeparator ?? "."
        if let commaRange = str.range(of: separator) {
            str.removeSubrange(commaRange.lowerBound..<str.endIndex)
            roundedSatoshi = str
            amount = UInt64(roundedSatoshi!) ?? 0
        }
    }
    
    private func roundSatoshi(from fiat: Decimal) {
        if tempLocalAmount < 1  {
            amount = 0
            delegate?.clearTextField()
        } else {
            if let dec = roundedSatoshi {
                delegate?.updateTextField(with: dec)
            }
            roundedSatoshi = nil
        }
    }
}

extension SendInputAddressVM: BillionKeyboardDelegate {
    func commaPressed() { }
    
    func deleteAllPressed() {
        self.changeAmountString("")
    }
    
    func numberPressed(_ num: Int) { }
    func deletePressed() { }
    
    // Use this to handle change currency from BillionKeyboard
    func changeCurrencyPressed(currency: CurrencyButtonState) {
        self.changeCurrencyState(currency)
        if currency == .satoshi {
            let fiat = fiatConverter.convertToFiat(btcValue: amount)
            roundSatoshi(from: fiat)
        }
    }
}
