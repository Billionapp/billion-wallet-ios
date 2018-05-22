//
//  SettingsRestoreViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 11/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsRestoreViewController: BaseViewController<SettingsRestoreVM> {
    
    typealias LocalizedStrings = Strings.Settings.Restore
    
    var router: SettingsRestoreRouter?
    
    // Dimension from designer
    private let textWidth: CGFloat = 240
    private let mneminicViewHeightKoef: CGFloat = 2
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    let alert = LocalizedStrings.alert
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show(mnemonic: viewModel.info.mnemonic)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSwipeDownGesture()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show(mnemonic: String) {
        dataManager.clear()
        
        let height = Layout.model.height * mneminicViewHeightKoef
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<LabelView>(item: .mnemonic(text: mnemonic, width: textWidth, height: height))
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
            guard let mainRouter = self?.router?.mainRouter else { return }
            handler(mainRouter)
        }
    }
    
}
