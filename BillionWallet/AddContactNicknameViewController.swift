//
//  AddContactNicknameViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 29/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddContactNicknameViewController: BaseViewController<AddContactNicknameVM> {
    
    weak var router: MainRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!

    override func configure(viewModel: AddContactNicknameVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    // MARK: - Private methods
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = NSLocalizedString("Add contact", comment: "")
        titledView.subtitle = NSLocalizedString("Enter a nickname to add a new one. Contact. Adding is done using data exchange through the server.", comment: "")
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
        
        let enterNickname = NSLocalizedString("Enter nickname", comment: "")
        let ok = NSLocalizedString("OK", comment: "")
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ColumnsView>(item: (containers: [
                    ViewContainer<InputSheetView>(item: (placeholder: enterNickname, text: nil, editable: true), actions: [nicknameChanged()]),
                    ViewContainer<ButtonSheetView>(item: .default(title: ok), actions: [okAction()])
                    ], distribution: .fill))]))
        menuStackView.resize(in: view)
    }
    
    fileprivate func nicknameChanged() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.change) { [weak self] data in
            guard let text = data.userInfo?["text"] as? String else { return }
            self?.viewModel.searchString = text
        }
    }

    // MARK: - Actions
    fileprivate func okAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.searchUser()
        }
    }

}

// MARK: - AddContactVMDelegate

extension AddContactNicknameViewController: AddContactNicknameVMDelegate {
    
    func showContactCard(for user: UserData) {
        router?.showNicknameCard(userData: user)
    }
    
}
