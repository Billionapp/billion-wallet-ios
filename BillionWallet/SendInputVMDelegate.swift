//
//  SendInputVMDelegate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.10.2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol SendInputVMDelegate: class {
    func didEnterLowAmount()
    func didEnterSafeInput()
    func didEnterUnsafeInput()
    func didOverflow()
    func didRecognizePaymentRequest()
    func didRecognizeFailureTransaction()
    func deleteLastSymbol()
    func clearTextField()
    func updateTextField(with satoshi: String)
    func switchInputToCommentMode()
}
