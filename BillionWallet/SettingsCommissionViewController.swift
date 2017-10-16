//
//  SettingsCommissionViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsCommissionViewController: BaseViewController<SettingsCommissionVM> {

    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        viewModel.delegate = self
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "Commission"
        titledView.subtitle = "Select the size of the Bitcoin network commission for sending transactions"
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }

    fileprivate func show(selectedCommission: FeeSize) {
        
        let sectionOne = FeeSize.all.map { commission in
            ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.selectable(title: commission.description, selected: commission == selectedCommission), actions: [selectAction()])
        }
        
        let sectionTwo = [
            ViewContainer<ColumnsView>(item: ([
                ViewContainer<ButtonSheetView>(item: .default(title: "OK"), actions: [saveAction()]),
                ViewContainer<ButtonSheetView>(item: .default(title: "Cancel"), actions: [dismissAction()])
                ], .fillEqually))
        ]
        
        let containers = [
            ViewContainer<SectionView>(item: sectionOne),
            ViewContainer<SectionView>(item: sectionTwo)
        ]
        
        dataManager.clear()
        dataManager.append(containers: containers)
        menuStackView.resize(in: view)
    }
    
    fileprivate func selectAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            guard let index = data.index, FeeSize.all.count > index else { return }
            self?.viewModel.selectedCommission = FeeSize.all[index]
        }
    }
    
    fileprivate func saveAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.save()
            self?.navigationController?.pop()
        }
    }
    
}

// MARK: - SettingsVMDelegate

extension SettingsCommissionViewController: SettingsCommissionVMDelegate {
   
    func commissionDidChange(_ commission: FeeSize) {
        show(selectedCommission: commission)
    }
    
}
