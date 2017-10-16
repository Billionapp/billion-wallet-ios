//
//  InputTextView.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol InputTextViewDelegate: class {
    func didChange(value: String)
    func didConfirm()
}

final class InputTextView: LoadableFromXibView {
    
    weak var output: InputTextViewDelegate? {
        didSet {
            // ???
            Logger.debug("???")
        }
    }
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    init(output: InputTextViewDelegate) {
        super.init(frame: UIScreen.main.bounds)
        self.output = output
        setupMenuStackView()
        show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = NSLocalizedString("Restore wallet", comment: "") as String
        titledView.closePressed = { [weak self] in
            self?.removeFromSuperview()
        }
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    func show() {
        dataManager.clear()
        
        dataManager.append(container:
            ViewContainer<ColumnsView>(item: ([
                ViewContainer<TextFieldSheetView>(item: .default(placeholder: "Enter recover phrase"), actions: [changeAction()]),
                ViewContainer<ButtonSheetView>(item: .default(title: "Ok"), actions: [okAction()])
                ], .fill))
        )
        menuStackView.resize(in: view)
    }
    
    // MARK: - Actions
    
    fileprivate func changeAction() -> ViewContainerAction<TextFieldSheetView> {
        return ViewContainerAction<TextFieldSheetView>(.change) { [weak self] data in
            guard
                let this = self,
                let text = data.userInfo?["text"] as? String else { return }
            this.output?.didChange(value: text)
            this.menuStackView.updateSize(in: this.view)
        }
    }
    
    fileprivate func okAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.view.endEditing(true)
            self?.output?.didConfirm()
        }
    }
    
}
