//
//  SettingsViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController<SettingsVM> {
    
    typealias LocalizedStrings = Strings.Settings.General
    
    enum TryingToOpen {
        case password
        case mnemonic
        case exitWallet
    }
    
    private var dataManager: StackViewDataManager!
    private var titledView: TitledView!
    private var menuStackView: MenuStackView!
    private var tryingToOpen: TryingToOpen?
    
    weak var router: MainRouter?
    
    override func configure(viewModel: SettingsVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
        show()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel.saveConfig()
        navigationController?.pop()
    }
    
    private func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
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
        
        let sectionOne =
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.destructive(title: LocalizedStrings.exitWallet), actions: [exitAction()])
                ])
        
        let sectionTwo =
            ViewContainer<SectionView>(item: [
                ViewContainer<InfoSheetView>(item: InfoSheetView.Model(title: LocalizedStrings.currency, subtitle: viewModel.currencies.first?.code ?? ""), actions: [currencyAction()]),
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.filetree(title: viewModel.securityButtonText), actions: [passwordAction()]),
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.filetree(title: LocalizedStrings.recovery), actions: [restoreAction()]),
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.filetree(title: LocalizedStrings.about), actions: [aboutAction()]),
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.default(title: LocalizedStrings.lock), actions: [lockAction()]),
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.default(title: LocalizedStrings.rescan), actions: [rescanAction()])
                ])
        
        dataManager.clear()
        dataManager.append(containers: [sectionOne, sectionTwo])
        
        #if ENABLE_FILE_LOGGING
            // FIXME: localize
            let sectionThree =
                ViewContainer<SectionView>(item: [
                    ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.default(title: "Share logs"), actions: [shareLog()])
                    ])
            dataManager.append(container: sectionThree)
        #endif
        
        menuStackView.resize(in: view)
    }
    
    fileprivate func currencyAction() -> ViewContainerAction<InfoSheetView> {
        return ViewContainerAction<InfoSheetView>(.click) { [weak self] data in
            self?.router?.showCurrencySettingsView(back: self?.backImage)
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
            self.viewModel.setIsLocked(true)
            self.navigationController?.pop()
        }
    }
    
    fileprivate func rescanAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [unowned self] data in
            self.viewModel.rescanBlockchain()
            self.navigationController?.pop()
        }
    }
    
    fileprivate func aboutAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.router?.showAboutSettingsView(back: self?.backImage)
        }
    }
    
    fileprivate func exitAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [unowned self] data in
            self.router?.showPasscodeView(passcodeCase: .lock, output: self.viewModel)
            self.tryingToOpen = .exitWallet
        }
    }
    
    #if ENABLE_FILE_LOGGING
    private func shareLog() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [unowned self] data in
            let file = Logger.getLogFile()
            let controller = UIActivityViewController(activityItems: [file as Any], applicationActivities: nil)
            self.present(controller, animated: true, completion: nil)
        }
    }
    #endif
}

// MARK: - SettingsVMDelegate

extension SettingsViewController: SettingsVMDelegate {
    
    func didComleteVerification() {
        guard let tryingToOpen = tryingToOpen else {
            return
        }
        
        switch tryingToOpen {
        case .password:
            router?.showPasswordSettingsView(back: backImage)
        case .mnemonic:
            router?.showRestoreSettingsView(with: .init(mnemonic: viewModel.mnemonic ?? "INVALID", title: LocalizedStrings.mnemonicTitle, handler: { [weak self] _ in
                self?.router?.navigationController.pop()
            }), back: self.backImage)
        case .exitWallet:
            let exitModalView = ExitModalView(viewModel: viewModel, router: router!, backImage: backImage)
            UIApplication.shared.keyWindow?.addSubview(exitModalView)
        }
    }
    
}
