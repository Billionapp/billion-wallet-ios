//
//  SettingsCurrencyViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 09/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SettingsCurrencyViewController: BaseViewController<SettingsCurrencyVM> {

    typealias LocalizedStrings = Strings.Settings.Currency
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        removeSwipeDownGesture()
        navigationController?.addSwipeDownPop()
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.subtitle
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show() {
        
        guard let selectedCurrency = viewModel.selectedCurrencies.first else {
            return
        }
        
        let currenciesItems = CurrencyFactory.allowedCurrenies().map { currency in
                ViewContainer<ButtonSheetView>(item: ButtonSheetView.Model.selectable(title: currency.fullName, selected: currency == selectedCurrency), actions: [selectAction()])
        }
        
        let sectionOne = ViewContainer<SectionView>(item: currenciesItems)

        let sectionTwo =
            ViewContainer<ColumnsView>(item: ([
                ViewContainer<SectionView>(item: [
                    ViewContainer<ButtonSheetView>(item: .default(title: LocalizedStrings.okButton), actions: [okAction()])]),
                ViewContainer<SectionView>(item: [
                    ViewContainer<ButtonSheetView>(item: .default(title: LocalizedStrings.cancelButton), actions: [dismissAction()])
                    ])
                ], .fillEqually))

        dataManager.clear()
        dataManager.append(containers: [sectionOne, sectionTwo])
        
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

