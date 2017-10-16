//
//  NotificationTransactionProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

public class NotificationTransactionProvider {
    
    // MARK: - Constants
    fileprivate let notificationTransactionAmount: UInt64 = 10000
    
    weak var walletProvider: WalletProvider?
    weak var paymentCodeProvider: PaymentCodesProvider?
    
    init(walletProvider: WalletProvider, paymentCodeProvider: PaymentCodesProvider) {
        self.walletProvider = walletProvider
        self.paymentCodeProvider = paymentCodeProvider
    }
    
    func createNotificationTransaction(for serializedString: String, fee: Fee) throws -> BRTransaction {
        let paymentCode = try PaymentCode(with: serializedString)
        let seedData = try getSeedData()
        
        let privatePaymentCodeData = BRWalletManager.getKeychainPaymentCodePriv(forAccount: 0)
        let privatePaymentCode = PrivatePaymentCode(priv: privatePaymentCodeData)
        
        let transaction = try getTransaction(for: paymentCode, privatePaymentCode: privatePaymentCode, fee: fee, seedData: seedData)
        try signTransaction(transaction)
        
        return transaction
    }
    
    func publish(_ transaction: BRTransaction, failure: (() -> Void)?, completion: (() -> Void)?) {
        walletProvider?.peerManager.publishTransaction(transaction) { error in
            switch error == nil {
            case true:
                completion?()
            case false:
                failure?()
            }
        }
    }
}

// MARK: - Private methods

extension NotificationTransactionProvider {
    
    fileprivate func getSeedData() throws -> Data {
        guard let seedData = walletProvider?.getSeedData() else {
            throw PaymentCodeError.noSeedData
        }
        return seedData
    }
    
    fileprivate func getTransaction(for paymentCode: PaymentCode, privatePaymentCode: PaymentCode, fee: Fee, seedData: Data) throws -> BRTransaction {
        
        guard let notificationAddress = paymentCode.notificationAddress else {
            throw PaymentCodeError.cannotRetriveNotificationAddress
        }

        let sigScript = Data(scriptPubKeyForAddress: notificationAddress)
        
        guard let satoshiPerBite = fee.satPerByte else {
            throw PaymentCodeError.invalidFee
        }
        
        guard let transaction = walletProvider?.manager.wallet?.transaction(forAmounts: [notificationTransactionAmount], toOutputScripts: [sigScript], andCustomFee: UInt64(satoshiPerBite)) else {
            throw PaymentCodeError.insufficientBalance
        }
        
        let outpoint = extractDesignatedOutpoint(from: transaction)

        guard let inputAddress = transaction.inputAddresses.first as? String else {
            throw PaymentCodeError.noInputs
        }

        let utxoPriv = try getPrivateKey(for: inputAddress, seedData: seedData)
        
        let opReturnScript = privatePaymentCode.notificationOpReturnScript(for: paymentCode, outpoint: outpoint, key: utxoPriv)
        
        guard let finalTransaction = walletProvider?.manager.wallet?.transaction(forAmounts: [notificationTransactionAmount, notificationTransactionAmount], toOutputScripts: [sigScript, opReturnScript], andCustomFee: UInt64(satoshiPerBite)) else {
            throw PaymentCodeError.insufficientBalance
        }
                        
        return finalTransaction
    }
    
    fileprivate func signTransaction(_ transaction: BRTransaction) throws {
        guard let signed = walletProvider?.manager.wallet?.sign(transaction, withPrompt: ""), signed else {
            throw PaymentCodeError.transactionNotSigned
        }
    }
    
    fileprivate func getPrivateKey(for address: String, seedData: Data) throws -> Priv {
        guard let allAddresses = BRAddressEntity.allObjects() as? [BRAddressEntity] else {
            throw PaymentCodeError.cannotGetUtxoPriv
        }
        
        if let addressEntity = allAddresses.filter({ $0.address == address }).first,
            let privString = walletProvider?.manager.sequence?.privateKey(UInt32(addressEntity.index), internal: addressEntity.internal, fromSeed: seedData) {
            
            
            guard let utxoBRKey = BRKey(privateKey: privString), let secret = utxoBRKey.secretKey else {
                throw PaymentCodeError.cannotGetUtxoPriv
            }
            
            return Priv(secret.pointee)
            
        } else if let pcPrivString = self.paymentCodeProvider?.getPrivateKeyForPCContact(address: address) {
            
            guard let utxoBRKey = BRKey(privateKey: pcPrivString), let secret = utxoBRKey.secretKey else {
                throw PaymentCodeError.cannotGetUtxoPriv
            }
            
            return Priv(secret.pointee)
        }
        
        throw PaymentCodeError.cannotGetUtxoPriv
        
    }
    
}

// MARK: - Errors

extension NotificationTransactionProvider {
    
    enum PaymentCodeError: LocalizedError {
        case noPrivForIndex
        case noInputs
        case noSeedData
        case cannotRetrivePaymentCode
        case invalidFee
        case insufficientBalance
        case notAuthenticated
        case transactionNotSigned
        case cannotRetriveNotificationAddress
        case cannotGetUtxoPriv
        
        var errorDescription: String? {
            return "\(self)"
        }
    }
    
}
