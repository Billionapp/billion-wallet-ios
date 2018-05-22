//
//  TxDetailsVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol TxDetailsVMDelegate: class {
    func transactionUpdated()
    func didReceiveNote(note: String)
}

class TxDetailsVM {
    
    typealias LocalizedStrings = Strings.TxDetails
    
    var direction: Transaction.Direction = .received
    var txSubtitle: String = ""
    var avatarImage: UIImage?
    var recipientText: String = ""
    var satoshiBalance: String = ""
    weak var delegate: TxDetailsVMDelegate?
    weak var walletProvider: BWalletManager!
    weak var notesProvider: TransactionNotesProvider!
    weak var urlHelper: UrlHelper!
    
    init(displayer: TransactionDisplayer,
         walletProvider: WalletProvider,
         notesProvider: TransactionNotesProvider,
         urlHelper: UrlHelper) {
        
        self.displayer = displayer
        self.walletProvider = walletProvider
        self.notesProvider = notesProvider
        self.urlHelper = urlHelper
        
        let txStatusNotify = Notification.Name(rawValue: "BRPeerManagerTxStatusNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupTransaction), name: txStatusNotify, object: nil)
    }
    
    var displayer: TransactionDisplayer {
        didSet {
            setupTransaction()
        }
    }
    
    var txStatus: String {
        return displayer.statusText
    }
    
    var transactionHash: String {
        return displayer.txHashString
    }
    
    var confirmationsFormat:  String {
        if displayer.confirmations == 1 {
            return LocalizedStrings.confirmationsTextSingle
        } else {
            return LocalizedStrings.confirmationTextPlural
        }
    }
    
    var note: String? {
        didSet {
            guard let note = note else { return }
            delegate?.didReceiveNote(note: note)
        }
    }
    
    private func isTransactionToFriend() -> Bool {
        if let _ = displayer.connection {
            return true
        } else {
            return false
        }
    }
    
    @objc
    func setupTransaction() {
        direction = displayer.isReceived ? .received : .sent
        if let contact = displayer.connection {
            txSubtitle = contact.givenName
            avatarImage = contact.avatarImage
            recipientText = displayer.partnerAddress!
        } else if direction == .received {
            txSubtitle = displayer.myAddress!
            recipientText = displayer.myAddress!
        } else {
            //FIXME: CRUSH
            txSubtitle = displayer.partnerAddress!
            recipientText = displayer.partnerAddress!
        }
        self.delegate?.transactionUpdated()
    }
    
    func getUserNoteIfNeeded() {
        if !displayer.isReceived {
            note = notesProvider.getUserNote(for: displayer.txHash)
        }
    }
    
    func gotoWebLink() {
        let url = urlHelper.urlForTxhash(hash: displayer.txHashString, isTestnet: walletProvider.isTestnet)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, completionHandler: nil)
        }
    }
}
