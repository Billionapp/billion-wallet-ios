//
//  SettingsRestoreVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsRestoreVM {
        
    struct Info {
        let mnemonic: String
        let title: String
        let handler: (MainRouter) -> Void
    }
    
    let info: Info
    let accountProvider: AccountManager?
    let icloudProvider: ICloud
    let defaultsProvider: Defaults
    
    init(info: Info, accountProvider: AccountManager, icloudProvider: ICloud, defaultsProvider: Defaults) {
        self.info = info
        self.accountProvider = accountProvider
        self.icloudProvider = icloudProvider
        self.defaultsProvider = defaultsProvider
    }
    
    func createWalletDigest() {
        _ = accountProvider?.createNewWalletDigest()
    }
}
