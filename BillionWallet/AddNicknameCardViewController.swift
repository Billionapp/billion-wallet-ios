//
//  AddNicknameCardViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddNicknameCardViewController: BaseViewController<AddNicknameCardVM> {
    
    weak var router: MainRouter?
    var gradientView: UIView!

    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    @IBOutlet weak var avatarImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientView()
        setupMenuStackView()
        show()
        
        if let avatarData = viewModel.contact.avatarData {
            avatarImageView.image = UIImage(data: avatarData)
        }
    }
    
    override func configure(viewModel: AddNicknameCardVM) {
        viewModel.delegate = self
    }
    
    // MARK: - Private methods
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = "Add contact"
        titledView.closePressed = { [weak self] in
            self?.navigationController?.pop()
        }
        
        view.addSubview(titledView)
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func setupGradientView() {
        self.gradientView = UIView(frame: CGRect(x: 0, y: 150, width: 414, height: 120))
        gradientView.isUserInteractionEnabled = false
        let gradient = CAGradientLayer()
        gradient.frame = gradientView.frame
        gradient.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        
        gradient.startPoint = CGPoint.init(x: 0.0,y: 1.0) // bottom
        gradient.endPoint = CGPoint.init(x: 0.0,y: 0.0) // top
        gradientView.layer.insertSublayer(gradient, at: 0)
        view.addSubview(gradientView)
        view.bringSubview(toFront: gradientView)
    }
    
    
    fileprivate func show() {
        dataManager.clear()
        
        let nickname = NSLocalizedString("Nickname:", comment: "")
        let nicknamePlaceholder = viewModel.contact.nickName != nil ? "@" + viewModel.contact.nickName! : nil
        let name = NSLocalizedString("Name:", comment: "")
        let namePlaceholder = NSLocalizedString("Nickname", comment: "")
        
        var containers: [Container] = [
            ViewContainer<SectionView>(item: [
                ViewContainer<ColumnsView>(item: ([
                    ViewContainer<LabelView>(item: .defails(text: nickname, width: 75)),
                    ViewContainer<InputSheetView>(item: (placeholder: nicknamePlaceholder, text: nil, editable: false), actions: []),
                    ], .fill)),
                ViewContainer<ColumnsView>(item: ([
                    ViewContainer<LabelView>(item: .defails(text: name, width: 75)),
                    ViewContainer<InputSheetView>(item: (placeholder: namePlaceholder, text: viewModel.contact.name, editable: false), actions: []),
                    ], .fill))
                ]),
            
            ViewContainer<ImageSheetView>(item: .init(image: viewModel.qrImage))]
        
        containers.append(ViewContainer<SectionView>(item: [
            ViewContainer<ColumnsView>(item: (containers: [
                ViewContainer<ButtonSheetView>(item: .default(title: NSLocalizedString("Add contact", comment: "")), actions: [addContact()])
                ], distribution: .fillEqually))
            ]))
        
        dataManager.append(containers: containers)
        menuStackView.resize(in: view)
    }
    
    // MARK: - Actions

    fileprivate func addContact() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.viewModel.addContact()
        }
    }
}

// MARK: - AddNicknameCardVMDelegate

extension AddNicknameCardViewController: AddNicknameCardVMDelegate {
    
    func contactSaved() {
        router?.navigationController.popToRootViewController(animated: false)
        router?.showContactsView(output: nil, mode: .default, back: UIImage())
    }
    
}
