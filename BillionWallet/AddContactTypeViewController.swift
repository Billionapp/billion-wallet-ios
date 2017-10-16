//
//  AddContactTypeViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddContactTypeViewController: BaseViewController<AddContactTypeVM> {
    
    weak var router: MainRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    override func configure(viewModel: AddContactTypeVM) {
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.scanProvider.scannedString != "" {
            viewModel.setFromProvider()
        }
    }
    
    // MARK: - Private methods
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = NSLocalizedString("Add contact", comment: "")
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
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .default(title: NSLocalizedString("Enter nickname", comment: "")), actions: [nicknameAction()]),
                ViewContainer<ButtonSheetView>(item: .default(title: NSLocalizedString("Enter address", comment: "")), actions: [addressAction()]),
                ViewContainer<ButtonSheetView>(item: .default(title: NSLocalizedString("Scan QR-code", comment: "")), actions: [qrCodeAction()])
                ]))
        menuStackView.resize(in: view)
    }
    
    // MARK: - Actions
    
    fileprivate func nicknameAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.router?.showAddContactNicknameView()
        }
    }
    
    fileprivate func addressAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.router?.showAddContactAddressView(address: "", txHash: nil)
        }
    }
    
    fileprivate func qrCodeAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.router?.showScanView(isPrivate: false)
        }
    }

}

// MARK: - AddContactTypeVMDelegate
extension AddContactTypeViewController: AddContactTypeVMDelegate {
    func contactAddressDidScan(address: String) {
        self.router?.showAddContactAddressView(address: address, txHash: nil)
    }
}
