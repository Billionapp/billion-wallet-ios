//
//  HistoryDisplayableVisitor.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class HistoryDisplayableVisitor: HistoryDisplayableVisitorProtocol {
    
    private let mainRouter: MainRouter
    
    init(mainRouter: MainRouter) {
        self.mainRouter = mainRouter
    }
    
    func showDetails(for displayer: TransactionDisplayer, cellY: CGFloat, backImage: UIImage) {
        if displayer.isOutgoingNotificationTx {
            mainRouter.showNotificationTransactionDetails(displayer: displayer, back: backImage, cellY: cellY)
        } else {
            mainRouter.showTransactionDetails(displayer: displayer, back: backImage, cellY: cellY)
        }
    }
    
    func showDetails(for displayer: FailureTxDisplayer, cellY: CGFloat, backImage: UIImage) {
        mainRouter.showTxFailureDetailsView(displayer: displayer, back: backImage, cellY: cellY)
    }

    func showDetails(for displayer: UserPaymentRequestDisplayer, cellY: CGFloat, backImage: UIImage) {
      mainRouter.showPaymentRequestDetailsView(displayer: displayer, back: backImage, cellY: cellY)
    }
    
    func showDetails(for displayer: SelfPaymentRequestDisplayer, cellY: CGFloat, backImage: UIImage) {
        mainRouter.showSelfPaymentRequestDetails(displayer: displayer, back: backImage, cellY: cellY)
    }

}

