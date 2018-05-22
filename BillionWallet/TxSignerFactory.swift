//
//  TxSignerFactory.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol TxSignerFactory {
    func signer() -> TxSigner
}

class StandardTxSignerFactory: TxSignerFactory {
    private let wallet: WalletProvider
    
    init(wallet: WalletProvider) {
        self.wallet = wallet
    }
    
    func signer() -> TxSigner {
        return StandardTxSigner(walletProvider: wallet)
    }
}
