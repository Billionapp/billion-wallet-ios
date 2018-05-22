//
//  SendInputContactVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class SendInputContactVM {
    typealias LocalizedStrings = Strings.SendInput
    
    var displayer: UserPaymentRequestDisplayer?
    private let maxSendAmountBuilder: MaxSendAmountBuilder
    let contact: PaymentCodeContactProtocol
    private let lockProvider: LockProvider
    let tapticService: TapticService
    weak var walletProvider: WalletProvider!
    
    private var roundedSatoshi: String?
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
    private var tempLocalAmount: Double = 0
    
    var delegate: SendInputVMDelegate?
    
    let receiverImageRepr: Dynamic<UIImage?>
    let title: Dynamic<String>
    let subtitle: Dynamic<String>
    let inputAmountPrefix: Dynamic<String>
    let amountLabel: Dynamic<String>
    var failureTransaction: FailureTx?
    var inputfield = TextInputField()
    
    var isSynced: Bool {
        return walletProvider.syncProgress == 1.0
    }
    
    init(maxSendAmountBuilder: MaxSendAmountBuilder,
         contact: PaymentCodeContactProtocol,
         ratesProvider: RateProviderProtocol,
         defaultsProvider: Defaults,
         lockProvider: LockProvider,
         tapticService: TapticService,
         walletProvider: WalletProvider) {
        
        self.maxSendAmountBuilder = maxSendAmountBuilder
        self.contact = contact
        self.lockProvider = lockProvider
        self.currency = defaultsProvider.currencies.first!
        self.btcFormatter = Satoshi.formatter
        self.tapticService = tapticService
        self.walletProvider = walletProvider
        
        self.currencyInputState = .localCurrency
        self.inputAmountPrefix = Dynamic(currency.symbol)
        let rateSource = DefaultRateSource(rateProvider: ratesProvider)
        self.fiatConverter = FiatConverter(currency: currency, ratesSource: rateSource)
        self.maxSendAmount = maxSendAmountBuilder.zeroMaxSendAmount()
        self.amount = 0
        self.title = Dynamic(LocalizedStrings.title)
        self.subtitle = Dynamic(contact.givenName)
        self.receiverImageRepr = Dynamic(contact.avatarImage)
        self.amountLabel = Dynamic("")
        
        subscribeToNotifications()
        calculateMaxSendAmount()
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
        if let displayer = displayer {
            amount = UInt64(displayer.amount)
            delegate?.didRecognizePaymentRequest()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.calculateMaxSendAmount),
                                               name: .walletBalanceChangedNotificationName,
                                               object: nil)
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
            
            let separator = Locale.current.decimalSeparator ?? "."
            let replaced = amountString.replacingOccurrences(of: separator, with: ".")
            tempLocalAmount = Double(replaced) ?? 0
            let value = amountStringToDecimal(replaced)
            amount = fiatConverter.convertToBtc(fiatValue: value)
        }
    }
    
    func isSyncingNow() -> Bool {
        // FIXME: Do we really need this method?
        return false
    }
    
    private func isRedundantFractionDigits(amount: String) -> Bool {
        let separator = Locale.current.decimalSeparator ?? "."
        guard let commaIndex = amount.index(of: Array(separator).first!) else { return false }
        let decimalPartIndex = amount.index(after: commaIndex)
        let decimalPartString = amount[decimalPartIndex...]
        
        if decimalPartString.count > currency.fractionDigits { return true }
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

extension SendInputContactVM: BillionKeyboardDelegate {
    func commaPressed() {
        
    }
    
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
