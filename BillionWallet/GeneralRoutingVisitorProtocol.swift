//
//  GeneralRoutingProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 28/11/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol HistoryDisplayableVisitorProtocol {
    func showDetails(for displayer: TransactionDisplayer, cellY: CGFloat, backImage: UIImage)
    func showDetails(for displayer: FailureTxDisplayer, cellY: CGFloat, backImage: UIImage)
    func showDetails(for displayer: UserPaymentRequestDisplayer, cellY: CGFloat, backImage: UIImage)
    func showDetails(for displayer: SelfPaymentRequestDisplayer, cellY: CGFloat, backImage: UIImage)
}
