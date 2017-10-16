//
//  SettingsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController<SettingsVM> {
    
    enum TryingToOpen {
        case password
        case mnemonic
    }
    
    weak var router: MainRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    fileprivate var tryingToOpen: TryingToOpen?
    
    override func configure(viewModel: SettingsVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        show()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "Settings"
        titledView.closePressed = { [weak self] in
            self?.viewModel.saveConfig()
            self?.navigationController?.pop()
        }
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show() {
        
        let sectionOne = [ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.destructive(title: "Exit the wallet"), actions: [exitAction()])]
        
        let sectionTwo = [
            ViewContainer<InfoSheetView>(item: InfoSheetView.Model(title: "Currency", subtitle: viewModel.currencies.first?.symbol ?? ""), actions: [currencyAction()]),
            ViewContainer<InfoSheetView>(item: InfoSheetView.Model(title: "Commission", subtitle: viewModel.commission.description), actions: [commissionAction()])
        ]
        
        let sectionThree = [
            ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.filetree(title: "Touch ID and password"), actions: [passwordAction()]),
            ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.filetree(title: "Show recovery phrase"), actions: [restoreAction()]),
            ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.filetree(title: "About"), actions: [aboutAction()])
        ]
        
        let sectionFour = [ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.default(title: "Lock wallet now"), actions: [lockAction()])]
        
        let containers = [
            ViewContainer<SectionView>(item: sectionOne),
            ViewContainer<SectionView>(item: sectionTwo),
            ViewContainer<SectionView>(item: sectionThree),
            ViewContainer<SectionView>(item: sectionFour)
        ]
        
        dataManager.clear()
        dataManager.append(containers: containers)
        menuStackView.resize(in: view)
    }
    
    fileprivate func currencyAction() -> ViewContainerAction<InfoSheetView> {
        return ViewContainerAction<InfoSheetView>(.click) { [weak self] data in
            self?.router?.showCurrencySettingsView()
        }
    }
    
    fileprivate func commissionAction() -> ViewContainerAction<InfoSheetView> {
        return ViewContainerAction<InfoSheetView>(.click) { [weak self] data in
            self?.router?.showCommissionSettingsView()
        }
    }
    
    fileprivate func passwordAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [unowned self] data in
            self.router?.showPasscodeView(passcodeCase: .lock, output: self.viewModel)
            self.tryingToOpen = .password
        }
    }
    
    fileprivate func restoreAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [unowned self] data in
            self.router?.showPasscodeView(passcodeCase: .lock, output: self.viewModel)
            self.tryingToOpen = .mnemonic
        }
    }
    
    fileprivate func lockAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [unowned self] data in
            self.viewModel.keychain.isLocked = true
            self.navigationController?.pop()
        }
    }
    
    fileprivate func aboutAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.router?.showAboutSettingsView()
        }
    }
    
    fileprivate func exitAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            let exitModalView = ExitModalView.init(viewModel: (self?.viewModel)!, router: (self?.router)!)
            UIApplication.shared.keyWindow?.addSubview(exitModalView)
        }
    }
}

// MARK: - SettingsVMDelegate

extension SettingsViewController: SettingsVMDelegate {
    
    func didComleteVerification() {
        guard let tryingToOpen = tryingToOpen else {
            return
        }
        
        switch tryingToOpen {
        case .password:
            router?.showPasswordSettingsView()
        case .mnemonic:
            router?.showRestoreSettingsView(with: .init(mnemonic: viewModel.mnemonic ?? "INVALID", title: "Back", handler: { [weak self] _ in
                self?.router?.navigationController.pop()
            }))
        }
    }
    
}
