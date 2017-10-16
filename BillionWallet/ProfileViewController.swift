//
//  ProfileViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class  ProfileViewController: BaseViewController< ProfileVM> {
    
    weak var router: MainRouter?
    
    var imagePicker = ImagePicker(sourceType: .photoLibrary)
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    fileprivate var avatarViewContainer: ViewContainer<AvatarSheetView>!
    var backForBlur: UIImage?
    
    override func configure(viewModel: ProfileVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupMenuStackView()
        setBlurBackground()
        show()
    }
    
    // MARK: - Private methods
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = NSLocalizedString("Wallet", comment: "")
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
        
        let nick = NSLocalizedString("Nick:", comment: "")
        let enterNick = NSLocalizedString("Enter nickname", comment: "")
        let cancel = NSLocalizedString("Cancel", comment: "")
        let ok = NSLocalizedString("OK", comment: "")
        let text = NSLocalizedString("To add contacts and create transactions for contacts\nneed to add your nickname and name", comment: "")
        
        var avatarImage: UIImage?
        if let photoData = viewModel.userData?.imageData {
            avatarImage = UIImage(data: photoData)
        }
        
        avatarViewContainer = ViewContainer<AvatarSheetView>(item: avatarImage, actions: [selectPhoto()])
        
        dataManager.append(containers: [
            ViewContainer<ImageSheetView>(item: .init(image: viewModel.getPaymentCodeQRImage() ?? UIImage())),
            ViewContainer<LabelView>(item: .description(text: text)),
                ViewContainer<ColumnsView>(item: ([
                    avatarViewContainer,
                        ViewContainer<ColumnsView>(item: ([
                            ViewContainer<LabelView>(item: .defails(text: nick, width: 60)),
                            ViewContainer<InputSheetView>(item: (placeholder: enterNick, text: viewModel.userData?.nick, editable: true), actions: [nickChanged()])
                            ], .fill))
                    ], .fill)),

            ViewContainer<SectionView>(item: [
                ViewContainer<ColumnsView>(item: (containers: [
                    ViewContainer<ButtonSheetView>(item: .default(title: cancel), actions: [cancelAction()]),
                    ViewContainer<ButtonSheetView>(item: .default(title: ok), actions: [okAction()])
                    ], distribution: .fillEqually))
                ])
            ])
        menuStackView.resize(in: view)
    }
    
    // MARK: - Actions
    
    fileprivate func cancelAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] _ in
            self?.viewModel.cancel()
            self?.view.endEditing(true)
        }
    }
    
    fileprivate func okAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] _ in
            self?.view.endEditing(true)
            self?.viewModel.save()
        }
    }
    
    fileprivate func nickChanged() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.change) { [weak self] data in
            guard let nick = data.userInfo?["text"] as? String else { return }
            self?.viewModel.nick = nick
        }
    }
    
    fileprivate func selectPhoto() -> ViewContainerAction<AvatarSheetView> {
        return ViewContainerAction<AvatarSheetView>(.click) { [weak self] data in
            self?.presentPicker()
        }
    }
    
    func setBlurBackground() {
        if let backImage = backForBlur {
            let imageView = UIImageView(image: backImage)
            view.insertSubview(imageView, at: 0)
        }
    }

}

// MARK: - ProfileVMDelegate

extension ProfileViewController: ProfileVMDelegate {
    
    func update(userData: LocalUserData?) {
        show()
    }
    
    func closeView() {
        dismiss()
    }
    
}

// MARK: - MediaPickerDelegate

extension ProfileViewController: MediaPickerDelegate {
    
    func presentPicker() {
        presentMediaPicker(fromController: self, sourceType: .photoLibrary)
    }
    
    func didSelectFromMediaPicker(withImage image: UIImage) {
        if let resized = image.resized(toWidth: 500),  let data = UIImageJPEGRepresentation(resized, 0.5) as Data? {
            viewModel.photo = data
            avatarViewContainer.item = image
            avatarViewContainer.configure()
        }
    }
    
}
