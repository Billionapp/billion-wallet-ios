//
//  ImportKeyViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ImportKeyViewController: BaseViewController<ImportKeyVM>, UIImagePickerControllerDelegate {
    
    weak var mainRouter: MainRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    fileprivate var popup: PopupView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    override func configure(viewModel: ImportKeyVM) {
        viewModel.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard viewModel.scannerProvider.scannedString != "" else {return}
        viewModel.setFromProvider()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = NSLocalizedString("Private key import", comment: "")
        titledView.closePressed = { [weak self] in
            self?.navigationController?.pop()
        }
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show() {
        dataManager.clear()
        
        let titleEnter = NSLocalizedString("Enter private key", comment: "") as String
        let titleUse = NSLocalizedString("Use key from clipboard", comment: "") as String
        let titleScan = NSLocalizedString("Scan QR-Code", comment: "") as String
        let titleExtract = NSLocalizedString("Extract QR-Code from picture", comment: "") as String
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .filetree(title:titleEnter), actions:[enterPrivateKey()]),
                ViewContainer<ButtonSheetView>(item: .filetree(title:titleUse), actions:[useKeyFromClipboard()]),
                ViewContainer<ButtonSheetView>(item: .filetree(title:titleScan), actions:[scanFromQrCode()]),
                ViewContainer<ButtonSheetView>(item: .filetree(title:titleExtract), actions:[extractQrFromPicture()])
            ]))
        menuStackView.resize(in: view)
        
    }
    
    fileprivate func enterPrivateKey() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            guard let viewModel = self?.viewModel else { return }
            let importTextKeyView = InputTextView(output: viewModel)
            UIApplication.shared.keyWindow?.addSubview(importTextKeyView)
        }
    }
    
    fileprivate func useKeyFromClipboard() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.pasteFromClipboard()
        }
    }
    
    fileprivate func scanFromQrCode() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.mainRouter?.showScanView(isPrivate: true)
        }
    }
    
    fileprivate func extractQrFromPicture() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            self?.navigationController?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    fileprivate func pasteFromClipboard () {
        if let string = UIPasteboard.general.string {
            viewModel.key = string
        }
    }
    
    //MARK: ImagePicker Delegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            viewModel.pickedImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImportKeyVMDelegate
extension ImportKeyViewController: ImportKeyVMDelegate {
    
    func keyDidChange(key: String) {   }
    
    func startCheckingPrivateKey() {
        DispatchQueue.main.async {
            self.popup = PopupView.init(type: .loading, labelString: "Private key checking...")
            UIApplication.shared.keyWindow?.addSubview(self.popup!)
        }
    }
    
    func checkingPrivateKeyDidEnd(withError error: NSError?) {
        DispatchQueue.main.async {
            self.popup?.close()
            guard let er = error else {
                let amt = Int64(self.viewModel.txProvider.amount!) - Int64(self.viewModel.txProvider.fee!)
                let localCurrencyAmount = self.viewModel.walletProvider.manager.localCurrencyString(forAmount: amt)
                let amount = self.viewModel.walletProvider.manager.string(forAmount: amt)
                let address = self.viewModel.txProvider.tx?.inputAddresses[0] as! String
                let importKeyPublishView = ImportKeyPublishView(address: address, localCurrencyAmount: localCurrencyAmount, amount: amount, viewModel: self.viewModel)
                UIApplication.shared.keyWindow?.addSubview(importKeyPublishView)
                return
            }
            
            let popup = PopupView.init(type: .cancel, labelString: er.localizedDescription)
            UIApplication.shared.keyWindow?.addSubview(popup)
        }
    }
}
