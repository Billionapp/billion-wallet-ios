//
//  SetupBioViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SetupBioViewController: BaseViewController<SetupBioVM> {
    
    weak var router: MainRouter?
    typealias LocalizedString = Strings.SetupBio
    
    private var dataManager: StackViewDataManager!
    private var titledView: TitledView!
    private var menuStackView: MenuStackView!
    
    override func configure(viewModel: SetupBioVM) {
        super.configure(viewModel: viewModel)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        createPin()
        setupMenuStackView()
        show(isTouchIdEnabled: viewModel.isTouchIdEnabled)
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = viewModel.title
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show(isTouchIdEnabled: Bool) {
        
        let title = viewModel.switchTitle
        
        dataManager.clear()
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<SwitchSheetView>(item: (title: title, isOn: isTouchIdEnabled), actions: [touchIdAction()])
                ]))
        
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .default(title: LocalizedString.next), actions: [nextAction()])
                ]))
        menuStackView.resize(in: view)
    }
    
    fileprivate func touchIdAction() -> ViewContainerAction<SwitchSheetView> {
        return ViewContainerAction<SwitchSheetView>(.switch) { [weak self] data in
            guard let isOn = data.userInfo?["isOn"] as? Bool else { return }
            self?.viewModel.setup(isOn: isOn)
        }
    }
    
    fileprivate func createPin() {
        router?.showPasscodeView(passcodeCase: .createFirst, output: viewModel)
    }
    
    fileprivate func nextAction() -> ViewContainerAction<ButtonSheetView>{
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            DispatchQueue.global().async {
                if let image = self?.viewModel.iCloudPicture() {
                    let name = self?.viewModel.iCloudName()
                    DispatchQueue.main.async {
                        self?.router?.showSetupCard(image: image, name: name)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.router?.showSetupCard(image: nil, name: nil)
                    }
                }
            }
        }
    }
}

//MARK: SetupBioVMDelegate
extension SetupBioViewController: SetupBioVMDelegate {
    func didFinishSetup() {
        //
    }
}
