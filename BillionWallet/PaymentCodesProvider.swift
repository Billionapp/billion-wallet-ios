//
//  pcProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

public enum PaymentCodesError: Error {
    case linkExistingContactToTxFailed
    case createNewPaymentCodeContactFailed
    case deriveKeyFailed
}

extension PaymentCodesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .linkExistingContactToTxFailed:
            return NSLocalizedString("Failed link existing contact to transaction", comment: "")
        case .createNewPaymentCodeContactFailed:
            return NSLocalizedString("Failed creation new payment code contact", comment: "")
        case .deriveKeyFailed:
            return NSLocalizedString("Failed to restore seed from mnemonic", comment: "")
        }
    }
}

class PaymentCodesProvider: NSObject {
    
    private weak var accountProvider: AccountManager!
    private weak var apiProvider: API!
    private weak var walletProvider: WalletProvider!
    private weak var contactsProvider: ContactsProvider!
    private let transactionRelator: TransactionRelatorProtocol!
    private let transactionLinker: TransactionLinkerProtocol!
    
    init(accountProvider: AccountManager,
         walletProvider: WalletProvider,
         contactsProvider: ContactsProvider,
         apiProvider: API,
         transactionRelator: TransactionRelatorProtocol,
         transactionLinker: TransactionLinkerProtocol) {
        
        self.apiProvider = apiProvider
        self.accountProvider = accountProvider
        self.walletProvider = walletProvider
        self.contactsProvider = contactsProvider
        self.transactionRelator = transactionRelator
        self.transactionLinker = transactionLinker
    }
    
    // MARK: Initial generate PCs then wallet initialized
    func generatePaymentCodes(seedPhrase: String) throws {
        guard let selfSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil)
            else { throw PaymentCodesError.deriveKeyFailed }
        
        let selfPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: selfSeed)
        let selfPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: selfSeed)
        
        do {
            let selfPCPriv = try PrivatePaymentCode(priv: selfPCPrivData)
            let selfPC = try PaymentCode(pub: selfPCData)
            
            accountProvider.saveSelfPC(paymentCode: selfPC.serializedString)
            accountProvider.saveSelfPCPriv(paymentCodePriv: selfPCPriv.xPriv.data)
            
            if let notifyAddress = selfPC.notificationAddress {
                accountProvider.saveNotificationIdVer1(notificationId: notifyAddress)
            }
            
            selfPC.version = 0x02 //Set generate notification id only
            if let notifyAddressVer2 = selfPC.identifier?.data {
                accountProvider.saveNotificationIdVer2(notificationId: notifyAddressVer2)
            }
            
        } catch {
            throw PaymentCodeError.invalidPaymentCode(selfPCData.toHexString())
        }
    }
    
    func checkAllTransactions(with contact: ContactProtocol) -> [TxRelation]  {
        guard let wallet = try? walletProvider.getWallet() else { return [] }
        
        let empty = [TxRelation]()
        let transactions = wallet.allTransactions.map({ Transaction(brTransaction: $0, walletProvider: walletProvider) })
        guard transactions.count > 0 else { return empty }
        return transactionRelator.detectRelated(transactions, for: contact)
    }
    
    
    @objc
    func handleInputNotificationTransaction(transaction: Transaction) {
        Logger.debug("Notification tx found - \(transaction.txHash.data.hex)")
        
        let selfPCPrivData = accountProvider.getSelfCPPriv()
        guard
            let selfPCPriv = try? PrivatePaymentCode(priv: selfPCPrivData),
            let recoveredPCB = try? selfPCPriv.recoverCode(from: transaction.brTransaction) else { return }
        
        guard let wallet = try? walletProvider.getWallet() else {
             return
        }
        
        let recoveredPCstring = recoveredPCB.serializedString
        
        var contact = contactsProvider.paymentCodeProtocolContacts.first(where: { $0.uniqueValue == recoveredPCstring })
        if contact != nil {
            contact!.txHashes.insert(transaction.txHash.data.hex)
            Logger.debug(String(format:"Saving notification tx - %@ - for known contact %@", transaction.txHash.data.hex, contact!.givenName))
            contactsProvider.save(contact!)
            wallet.addAddressesAfterNotificationTxImediately(transaction.blockHeight)
            return
        }
        
        
        apiProvider?.findUser(pc: recoveredPCstring) { (result) in
            guard let wallet = try? self.walletProvider.getWallet() else { return }
            
            switch result {
            case .success(let user):
                var contact = FriendContact.create(unique: user.pc)
                if let name = user.name {
                    contact.displayName = name
                }
                contact.avatarData = user.avatarData
                contact.txHashes.insert(transaction.txHash.data.hex)
                contact.lastUsed = NSNumber(value: Double(0))
                
                Logger.debug("Saving friend contact for notification tx - \(transaction.txHash.data.hex)")
                self.contactsProvider.save(contact)
                wallet.addAddressesAfterNotificationTxImediately(transaction.blockHeight)
                
                let relations = self.checkAllTransactions(with: contact)
                self.transactionLinker.link(relations: relations, completion: { (linkedContact) in
                    self.contactsProvider.save(linkedContact)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .transactionsLinkedToContact, object: nil)
                    }
                })
                
            case .failure(let error):
                var contact = self.contactsProvider.getOrCreatePaymentCodeContact(paymentCode: recoveredPCstring)
                
                contact.isArchived = false
                contact.txHashes.insert(transaction.txHash.data.hex)
                contact.lastUsed = NSNumber(value: Double(0))
                // FIXME: record incoming notification txhash for contact
                
                Logger.debug("Billion card fetch failed: \(error.localizedDescription). Saving payment code contact for notification tx - \(transaction.txHash.data.hex)")
                self.contactsProvider.save(contact)
                wallet.addAddressesAfterNotificationTxImediately(transaction.blockHeight)
                
                let relations = self.checkAllTransactions(with: contact)
                self.transactionLinker.link(relations: relations, completion: { (linkedContact) in
                    self.contactsProvider.save(linkedContact)
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .transactionsLinkedToContact, object: nil)
                    }
                })
            }
        }
    }
    
    class func isValidPaymentCode(str: String) -> Bool {
        guard let data = str.base58checkAsData else {return false}
        guard data.count == 81 && data[0] == 0x47 else {
            return false
        }
        
        return true
    }
    
    func rescanFromBlock(blockHeight: UInt32) {
        if (blockHeight < walletProvider.lastBlockHeight) {
            walletProvider.rescan(from: blockHeight)
        }
    }

    @objc
    func getPrivateKeyForPCContact(address: String) -> String? {
        
        guard let paymentCodeContacts = contactsProvider?.paymentCodeProtocolContacts else {
            return nil
        }
        
        var index: Int? = nil
        var paymentCodeContact: PaymentCodeContactProtocol?
        for contact in paymentCodeContacts {
            if let i = contact.receiveAddresses.index(of: address) {
                index = i
                paymentCodeContact = contact
                // Get just the first contact, that matches
                break
            }
        }
        
        guard
            let pc = paymentCodeContact?.paymentCode,
            let contactPC = try? PaymentCode(with: pc),
            let keyIndex = index else {
                return nil
        }
        
        let privatePCData = accountProvider.getSelfCPPriv()
        guard let privatePC = try? PrivatePaymentCode(priv: privatePCData) else {
            return nil
        }
        
        return privatePC.ethemeralReceiveBRKey(from: contactPC, i: UInt32(keyIndex))?.privateKey
    }
}

