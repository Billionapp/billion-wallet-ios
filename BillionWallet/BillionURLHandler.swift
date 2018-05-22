//
//  BillionURLHandler.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20.11.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol BillionUrlHandlerProtocol {
    func handle(urlData: BillionUrlData)
}

class BillionUrlHandler: BillionUrlHandlerProtocol {
    
    private let router: MainRouter
    private let accountProvider: AccountManager
    
    init(router: MainRouter, accountProvider: AccountManager) {
        self.router = router
        self.accountProvider = accountProvider
    }
    
    func handle(urlData: BillionUrlData) {
        if urlData.pc != accountProvider.getSelfPCString() {
            router.showSearchContactView(back: #imageLiteral(resourceName: "background_black"), billionCode: urlData.pc)
        } else {
            let errorString = NSLocalizedString("Link contains your own Payment Code", comment: "")
            let popup = PopupView(type: .cancel, labelString: errorString)
            UIApplication.shared.keyWindow?.addSubview(popup)
        }
    }
}
