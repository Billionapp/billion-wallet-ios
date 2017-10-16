//
//  SettingsCurrencyViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsCurrencyViewController: BaseViewController<SettingsCurrencyVM> {

    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "Currency"
        titledView.subtitle = "Select currencies to display the balance of your purse. The first currency in the list is the main one and is displayed on the main screen"
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show() {
        
        guard let selectedCurrency = viewModel.selectedCurrencies.first else {
            return
        }
        
        let sectionOne = CurrencyFactory.allowedCurrenies().map { currency in
            ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.selectable(title: currency.fullName, selected: currency == selectedCurrency), actions: [selectAction()])
        }
        
        let sectionTwo = [
            ViewContainer<ColumnsView>(item: ([
                ViewContainer<ButtonSheetView>(item: .default(title: "OK"), actions: [okAction()]),
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
    
    func okAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.save()
            self?.navigationController?.pop()
        }
    }
    
    fileprivate func selectAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            guard let index = data.index, CurrencyFactory.allowedCurrenies().count > index else { return }
            self?.viewModel.selectedCurrencies = [CurrencyFactory.allowedCurrenies()[index]]
            self?.show()
        }
    }
    
}

