//
//  ImportKeyVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import Foundation

protocol ImportKeyVMDelegate: class {
    func keyDidChange(key: String)
    func startCheckingPrivateKey()
    func checkingPrivateKeyDidEnd(withError error: NSError?)
}

class ImportKeyVM {
    
    let scannerProvider: ScannerDataProvider
    let walletProvider: WalletProvider
    let txProvider: TransactionProvider
    var privateKey: String?

    weak var delegate: ImportKeyVMDelegate? {
        didSet {
            
        }
    }
    
    var key:String = "" {
        didSet {
            scannerProvider.scannedString = key
            setFromProvider()
        }
    }
    
    var pickedImage: UIImage? {
        didSet {
            if let image = pickedImage {
                performQRCodeDetection(image: CIImage(image:image)!, success: { (detectedString) in
                    key = detectedString
                }) { (errorString) in
                    let popup = PopupView.init(type: .cancel, labelString: NSLocalizedString(errorString, comment: ""))
                    UIApplication.shared.keyWindow?.addSubview(popup)
                }
            }
        }
    }
    
    // MARK: - Lifecycle
    init(provider: ScannerDataProvider, walletProvider: WalletProvider, txProvider: TransactionProvider) {
        self.walletProvider = walletProvider
        self.scannerProvider = provider
        self.txProvider = txProvider
    }
    
    func setFromProvider () {
        let str = scannerProvider.scannedString
        checkQrOutput(str: str, success: { [weak self] (tx, fee, amount) in
            self?.txProvider.tx = tx
            self?.txProvider.fee = fee
            self?.txProvider.amount = amount
            self?.delegate?.checkingPrivateKeyDidEnd(withError: nil)
            self?.scannerProvider.scannedString = ""
        }) { [weak self] (error) in
            self?.delegate?.checkingPrivateKeyDidEnd(withError: error)
            self?.scannerProvider.scannedString = ""
        }
    }
    
    func start() {
        guard let tx = txProvider.tx else {
            let popUp = PopupView(type: .cancel, labelString: "Transaction creating error")
            UIApplication.shared.keyWindow?.addSubview(popUp)
            
            return
        }
        
        guard let fee = txProvider.fee else  {
            let popUp = PopupView(type: .cancel, labelString: "Fee computation error")
            UIApplication.shared.keyWindow?.addSubview(popUp)
            return
        }
        
        let popUp = PopupView(type: .loading, labelString: "Receiving...")
        UIApplication.shared.keyWindow?.addSubview(popUp)
        // FIXME: MOVE TO ANOTHER METHOD
//        walletProvider.manager.publish(transaction: tx, withFee: fee, success: {
//            DispatchQueue.main.async {
//                popUp.close()
//                let popUp = PopupView(type: .ok, labelString: "Success")
//                UIApplication.shared.keyWindow?.addSubview(popUp)
//            }
//        }) { (error) in
//            DispatchQueue.main.async {
//                let popUp = PopupView(type: .cancel, labelString: error.localizedDescription)
//                UIApplication.shared.keyWindow?.addSubview(popUp)
//            }
//        }
    }

    func checkQrOutput(str: String, success: @ escaping (BRTransaction, UInt64, UInt64) -> Void, failure: @escaping(NSError) -> Void)  {
        delegate?.startCheckingPrivateKey()
        // FIXME: MOVE TO ANOTHER METHOD
//        walletProvider.manager.generateTransaction(withPrivate: str, success: success, failure: failure)
    }
}

// MARK: - InputTextViewDelegate
extension ImportKeyVM: InputTextViewDelegate {
    
    func didChange(value: String) {
        scannerProvider.scannedString = value
    }
    
    func didConfirm() {        
        setFromProvider()
    }
    
}


