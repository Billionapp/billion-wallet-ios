//
//  NotificationTxDetailsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12/12/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

class NotificationTxDetailsVM {
    let walletProvider: WalletProvider
    let displayer: TransactionDisplayer
    let urlHelper: UrlHelper!
    var cellY: CGFloat
    
    init(displayer: TransactionDisplayer,
         walletProvider: WalletProvider,
         cellY: CGFloat,
         urlHelper: UrlHelper) {
        
            self.walletProvider = walletProvider
            self.displayer = displayer
            self.cellY = cellY
            self.urlHelper = urlHelper
    }
    
    var localCurrencyAmount: String {
        return displayer.localCurrencyAmount
    }
    
    var confirmations: String {
        return displayer.confirmationsText
    }
    
    var contactAvatar: UIImage? {
        return displayer.avatarImage
    }
    
    var satoshiAmount: String {
        return displayer.totalSatoshiAmount!
    }
    
    func gotoWebLink() {
        let url = urlHelper.urlForTxhash(hash: displayer.txHashString, isTestnet: walletProvider.isTestnet)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
}
