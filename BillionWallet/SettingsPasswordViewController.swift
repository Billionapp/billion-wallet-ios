//
//  SettingsPasswordViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsPasswordViewController: BaseViewController<SettingsPasswordVM> {
    
    typealias LocalizedStrings = Strings.Settings.Password
    
    weak var router: MainRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        viewModel.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSwipeDownGesture()
        navigationController?.addSwipeDownPop()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = viewModel.title
        titledView.subtitle = viewModel.subtitle
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show(isTouchIdEnabled: Bool) {
        
        let title = viewModel.securityButtonTitle
        
        dataManager.clear()
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<SwitchSheetView>(item: (title: title, isOn: isTouchIdEnabled), actions: [touchIdAction()]),
                ViewContainer<ButtonSheetView>(item: .filetree(title: LocalizedStrings.passwordChange), actions: [changePasswordAction()])
                ]))
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .default(title: LocalizedStrings.back), actions: [dismissAction()])
                ]))
        menuStackView.resize(in: view)
    }
    
    fileprivate func touchIdAction() -> ViewContainerAction<SwitchSheetView> {
        return ViewContainerAction<SwitchSheetView>(.switch) { [weak self] data in
            guard let isOn = data.userInfo?["isOn"] as? Bool else { return }
            self?.viewModel.isTouchIdEnabled = isOn
        }
    }
    
    fileprivate func changePasswordAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.router?.showPasscodeView(passcodeCase: .updateOld, output: self?.viewModel)
        }
    }
    
}

// MARK: - SettingsPasswordVMDelegate

extension SettingsPasswordViewController: SettingsPasswordVMDelegate {
    
    func didEnableTouchId(_ isOn: Bool) {
        show(isTouchIdEnabled: isOn)
    }
    
    func didPasswordChanged() {
        let popup = PopupView(type: .ok, labelString: LocalizedStrings.passwordChanged)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
}
