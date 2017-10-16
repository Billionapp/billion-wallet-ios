//
//  AddWalletViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddWalletViewController: BaseViewController<AddWalletVM>, AddWalletVMDelegate {
    
    var router: AddWalletRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    override func configure(viewModel: AddWalletVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "Add wallet"
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    

    fileprivate func show() {
        dataManager.clear()
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .default(title: "Create new wallet"), actions: [newAction()]),
                ViewContainer<ButtonSheetView>(item: .default(title: "Restore wallet"), actions: [restoreAction()])
                ]))
        menuStackView.resize(in: view)
    }
    
    fileprivate func newAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.generateWallet()
        }
    }
    
    fileprivate func restoreAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            guard let viewModel = self?.viewModel else { return }
            let importTextKeyView = InputTextView(output: viewModel)
            importTextKeyView.tag = 999
            UIApplication.shared.keyWindow?.addSubview(importTextKeyView)
        }
    }
    
    func phraseDidSet(phrase: String) {
        let title: String = NSLocalizedString("Next", comment: "")
        let info = SettingsRestoreVM.Info(mnemonic: phrase, title: title, handler: { router in
            router.showGeneralView()
        })
        self.router?.showNewWalletView(with: info)
    }
    
    func phraseDidRecoved() {
        router?.showRestoreWalletView()
        UIApplication.shared.keyWindow?.viewWithTag(999)?.removeFromSuperview()
    }
}
