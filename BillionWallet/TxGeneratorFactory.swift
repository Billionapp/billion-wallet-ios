//
//  TxGeneratorFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxGeneratorFactory {
    func generatorForAddress(_ address: String) -> TxGenerator
    func generatorForPCContact(_ pcRecipient: PaymentCodeContactProtocol) -> TxGenerator
}

class DefaultTxGeneratorFactory: TxGeneratorFactory {
    private let wallet: WalletProvider
    private let txBuilder: TransactionBuilder
    private let accountManager: AccountManager
    
    init(wallet: WalletProvider, accountManager: AccountManager ) {
        self.wallet = wallet
        self.txBuilder = StandardTransactionBuilder(wallet: wallet)
        self.accountManager = accountManager
    }
    
    func generatorForAddress(_ address: String) -> TxGenerator {
        return AddressTxGenerator(walletProvider: wallet, txBuilder: txBuilder, address: address)
    }
    
    func generatorForPCContact(_ pcRecipient: PaymentCodeContactProtocol) -> TxGenerator {
        // FIXME: change all force unwraps to throws
        if pcRecipient.isNotificationTxNeededToSend {
            let pcString = accountManager.getSelfPCString()
            let selfPC = try! PaymentCode(with: pcString)
            
            return PCv1TxGenerator(walletProvider: wallet, selfPc: selfPC, txBuilder: txBuilder, pcContact: pcRecipient)
        } else {
            return AddressTxGenerator(walletProvider: wallet, txBuilder: txBuilder, address: pcRecipient.addressToSend()!)
        }
    }
}
