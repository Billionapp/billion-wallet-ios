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
}

extension PaymentCodesError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .linkExistingContactToTxFailed:
            return NSLocalizedString("Failed link existing contact to transaction", comment: "")
        case .createNewPaymentCodeContactFailed:
            return NSLocalizedString("Failed creation new payment code contact", comment: "")
        }
    }
}

class PaymentCodesProvider: NSObject {
    
    weak var accountProvider: AccountManager?
    weak var walletProvider: WalletProvider?
    weak var contactsProvider: ContactsProvider?
    
    init(accountProvider: AccountManager, walletProvider: WalletProvider, contactsProvider: ContactsProvider) {
        self.accountProvider = accountProvider
        self.walletProvider = walletProvider
        self.contactsProvider = contactsProvider
    }
    
    // MARK: Initial generate PCs then wallet initialized
    func generatePaymentCodes(seedPhrase: String) {
        guard let selfSeed = BRBIP39Mnemonic().deriveKey(fromPhrase: seedPhrase, withPassphrase: nil)
            else { return }
        
        let selfPCPrivData = BIP44Sequence().paymentCodePrivateKey(forAccount: 0, fromSeed: selfSeed)
        let selfPCData = BIP44Sequence().paymentCode(forAccount: 0, fromSeed: selfSeed)
        
        let selfPCPriv = PrivatePaymentCode(priv: selfPCPrivData)
        guard let selfPC = try? PaymentCode(pub: selfPCData) else {
            Logger.error(PaymentCodeError.invalidPaymentCode(selfPCData.toHexString()).localizedDescription)
            return
        }
        
        accountProvider?.saveSelfPC(paymentCode: selfPC.serializedString)
        accountProvider?.saveSelfPCPriv(paymentCodePriv: selfPCPriv.xPriv.data)
        
        if let notifyAddress = selfPC.notificationAddress {
            accountProvider?.saveNotificationIdVer1(notificationId: notifyAddress)
        }
        
        selfPC.version = 0x02 //Set generate notification id only
        if let notifyAddressVer2 = selfPC.identifier?.data {
            accountProvider?.saveNotificationIdVer2(notificationId: notifyAddressVer2)
        }
    }
    
    @objc func handleInputNotificationTransaction(transaction: BRTransaction) {
        Logger.info("NT Found")
        self.accountProvider = AccountManager.shared
        if let selfPCPrivData = accountProvider?.getSelfCPPriv() {
            let selfPCPriv = PrivatePaymentCode(priv: selfPCPrivData)
            guard let recoveredPCB = selfPCPriv.recoverCode(from: transaction) else { return }
            
            let recoveredPCstring = recoveredPCB.serializedString
            // TODO: refactor
            let prov = ContactsProvider()
            
            var contact = prov.getOrCreatePaymentCodeContact(paymentCode: recoveredPCstring)
            contact.txHashes.insert(UInt256S(transaction.txHash).data.hex)
            contact.notificationTxHash = UInt256S(transaction.txHash).data.hex
            
            do {
                Logger.info("SAVING new Contact")
                try prov.save(contact)
                walletProvider?.manager.wallet?.addAddressesAfterNotificationTxImediately()
            } catch {
                Logger.log(PaymentCodesError.createNewPaymentCodeContactFailed.localizedDescription, level: .error)
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
        //Rescan from notification block
        if let lastBlockHeight = BRPeerManager.sharedInstance()?.lastBlockHeight {
            if (blockHeight < lastBlockHeight) {
                BRPeerManager.sharedInstance()?.rescan(from: blockHeight)
            }
        }
    }
    
    @objc
    func getPrivateKeyForPCContact(address: String) -> String? {
        
        guard let paymentCodeContacts = contactsProvider?.paymenctCodeProtocolContacts else {
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
        
        let privatePCData = BRWalletManager.getKeychainPaymentCodePriv(forAccount: 0)
        let privatePC = PrivatePaymentCode(priv: privatePCData)
        
        return privatePC.ethemeralReceiveBRKey(from: contactPC, i: UInt32(keyIndex))?.privateKey
    }
}
