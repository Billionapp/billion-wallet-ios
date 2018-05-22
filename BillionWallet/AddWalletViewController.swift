//
//  AddWalletViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddWalletViewController: BaseViewController<AddWalletVM>, AddWalletVMDelegate {
    
    typealias LocalizedStrings = Strings.AddWallet
    
    var router: AddWalletRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    fileprivate var animatedView: UIView?
    
    override func configure(viewModel: AddWalletVM) {
        viewModel.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(animatePhones), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMenuStackView()
        show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animatePhones()
    }
    
    @objc fileprivate func animatePhones() {
        if animatedView != nil { animatedView?.removeFromSuperview() }
        let height = UIScreen.main.bounds.height
        let width = UIScreen.main.bounds.width
        let y = height * 0.1535
        let animHeight = height * 0.5978
        let animatedFrame = CGRect(x: 0, y: y, width: width, height: animHeight)
        animatedView = UIView(frame: animatedFrame)
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = animatedView!.bounds
        animatedView?.layer.addSublayer(gradient)
        gradient.zPosition = 1
        self.view.addSubview(animatedView!)
        
        let leftFrame = CGRect(x: width * -0.0304, y: 0, width: width * 0.5314, height: animHeight)
        let leftIV = UIImageView(frame: leftFrame)
        leftIV.image = UIImage(named: "addWalletLeft".nibName())
        leftIV.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        animatedView?.addSubview(leftIV)
        
        let rightFrame = CGRect(x: width * (1.0304 - 0.5314), y: 0, width: width * 0.5314, height: animHeight)
        let rightIV = UIImageView(frame: rightFrame)
        rightIV.image = UIImage(named: "addWalletRight".nibName())
        animatedView?.addSubview(rightIV)
        
        UIView.animate(withDuration: 1.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            leftIV.transform = CGAffineTransform.identity
            rightIV.transform = CGAffineTransform.init(scaleX: 0.8, y: 0.8)
        })
    }
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    

    fileprivate func show() {
        dataManager.clear()
        dataManager.append(container:
            ViewContainer<SectionView>(item: [
                ViewContainer<ButtonSheetView>(item: .default(title: LocalizedStrings.createWallet), actions: [newAction()]),
                ViewContainer<ButtonSheetView>(item: .default(title: LocalizedStrings.restoreWallet), actions: [restoreAction()])
                ]))
        menuStackView.resize(in: view)
    }
    
    fileprivate func newAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.generateWallet()
        }
    }
    
    fileprivate func restoreAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            guard let viewModel = self?.viewModel else { return }
            let importTextKeyView = InputTextView(output: viewModel)
            importTextKeyView.tag = 999
            UIApplication.shared.keyWindow?.addSubview(importTextKeyView)
        }
    }
    
    func phraseDidSet(phrase: String) {
        let title: String = LocalizedStrings.next
        let info = SettingsRestoreVM.Info(mnemonic: phrase, title: title, handler: { router in
            router.showGeneralContainerView()
            router.showBiometricSetup()
            router.showPrivacyPolicy()
        })
        self.router?.showNewWalletView(with: info)
    }
    
    func phraseDidRecoved() {
        router?.showRestoreWalletView()
        UIApplication.shared.keyWindow?.viewWithTag(999)?.removeFromSuperview()
    }
}
