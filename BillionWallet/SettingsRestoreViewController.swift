//
//  SettingsRestoreViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsRestoreViewController: BaseViewController<SettingsRestoreVM> {
    
    var router: SettingsRestoreRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    let alert = "Do not let anyone see your recovery phrase. If you let someone know your recovery phrase - it is equal to give your money to this person with a possibility to use it at any time. If you lose your mobile device you’ll need this phrase to recover your wallet. Please write down your recovery phrase."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show(mnemonic: viewModel.info.mnemonic)
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "Recovery phrase"
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show(mnemonic: String) {
        dataManager.clear()
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<LabelView>(item: .default(text: mnemonic))
                ]))
        
        dataManager.append(container:
            ViewContainer<LabelView>(item: .description(text: alert)))
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .default(title: viewModel.info.title), actions: [action(with: viewModel.info.handler)])]))
        menuStackView.resize(in: view)
    }
    
    fileprivate func action(with handler: @escaping (MainRouter) -> Void) -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.createWalletDigest()

            guard let mainRouter = self?.router?.mainRouter else { return }
            handler(mainRouter)
        }
    }
    
}
