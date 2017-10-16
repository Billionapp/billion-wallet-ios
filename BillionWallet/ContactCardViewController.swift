//
//  ContactCardViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ContactCardViewController: BaseViewController<ContactCardVM>, UIImagePickerControllerDelegate {
    weak var router: MainRouter?
    fileprivate let picker = UIImagePickerController()
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    
    fileprivate var leftButton: ViewContainer<ButtonSheetView>?
    fileprivate var rightButton: ViewContainer<ButtonSheetView>?
    fileprivate var imageContainer: ViewContainer<ImageSheetView>?
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    
    var gradientView: UIView!
    
    override func configure(viewModel: ContactCardVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        setupMenuStackView()
        show()
        configureAvatar()
        
        avatarImageView.addBlackGradientLayer()
    }
    
    
    // MARK: - Private methods
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = viewModel.contact.displayName
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
        dataManager.stackView.addArrangedSubview(UIView())
        
        let name = NSLocalizedString("Name:", comment: "")
        let namePlaceholder = NSLocalizedString("Nickname", comment: "")
        
        let placeholder = viewModel.contact.description.smart + ":"
        let text = viewModel.contact.uniqueValue
        
        imageContainer = ViewContainer<ImageSheetView>(item: .init(image: viewModel.qrImage))
        
        var containers: [Container] = [
            ViewContainer<SectionView>(item: [
                ViewContainer<ColumnsView>(item: ([
                    ViewContainer<LabelView>(item: .defails(text: placeholder, width: 75)),
                    ViewContainer<InputSheetView>(item: (placeholder: placeholder, text: text, editable: false), actions: [begin(), end(), addressChanged()]),
                    ], .fill)),
                ViewContainer<ColumnsView>(item: ([
                    ViewContainer<LabelView>(item: .defails(text: name, width: 75)),
                    ViewContainer<InputSheetView>(item: (placeholder: namePlaceholder, text: viewModel.contact.displayName, editable: true), actions: [begin(), end(), nameChanged()]),
                    ], .fill))
                ]),
            imageContainer!
        ]
        
        leftButton = deleteContactButton()
        // TODO: Share button will be implemented by next sprint
        //rightButton = shareContactButton()
        
        containers.append(ViewContainer<SectionView>(item: [
            ViewContainer<ColumnsView>(item: (containers: [
                leftButton!//,
                //rightButton!
                ], distribution: .fillEqually))
            ]))
        
        dataManager.append(containers: containers)
        menuStackView.resize(in: view)
    }
    
    fileprivate func showPicker() {
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    fileprivate func buttonsSection(editing: Bool) {
        if editing {
            leftButton?.item = cancelButton().item
            leftButton?.actions = cancelButton().actions
            rightButton?.item = okButton().item
            rightButton?.actions = okButton().actions
            showChangeAvatarButton(true)
        } else {
            view.endEditing(true)
            leftButton?.item = deleteContactButton().item
            leftButton?.actions = deleteContactButton().actions
            rightButton?.item = shareContactButton().item
            rightButton?.actions = shareContactButton().actions
            showChangeAvatarButton(false)
        }
        leftButton?.configure()
        rightButton?.configure()
    }
    
    // MARK: - Actions 
    fileprivate func begin() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.begin) { [weak self] data in
            guard let weakSelf = self else { return }
            weakSelf.buttonsSection(editing: true)
            weakSelf.menuStackView.stackView.removeArrangedSubview(weakSelf.imageContainer!.view)
            weakSelf.imageContainer!.view.removeFromSuperview()
            weakSelf.titledView.closeButton.isHidden = true
        }
    }
    
    fileprivate func end() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.end) { [weak self] data in
            guard let weakSelf = self else { return }
            weakSelf.buttonsSection(editing: false)
            weakSelf.menuStackView.stackView.insertArrangedSubview(weakSelf.imageContainer!.view, at: 2)
            weakSelf.titledView.closeButton.isHidden = false
        }
    }
    
    fileprivate func nameChanged() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.change) { [weak self] data in
            guard let text = data.userInfo?["text"] as? String else { return }
            self?.viewModel.newName = text
        }
    }
    
    fileprivate func addressChanged() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.change) {  data in
            guard let text = data.userInfo?["text"] as? String else { return }
        }
    }
    
    fileprivate func apply() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.buttonsSection(editing: false)
            self?.viewModel.updateContact()
        }
    }
    
    fileprivate func cancel() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            self?.buttonsSection(editing: false)
        }
    }
    
    fileprivate func delete() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] data in
            if let model = self?.viewModel,
                let router = self?.router {
                
                let archiveModalView = ArchiveModalView.init(viewModel: model, router: router)
                UIApplication.shared.keyWindow?.addSubview(archiveModalView)
            }
        }
    }
    
    // MARK: - View Containers
    fileprivate func okButton() -> ViewContainer<ButtonSheetView> {
        let okString = NSLocalizedString("OK", comment: "")
        return  ViewContainer<ButtonSheetView>(item: .default(title: okString), actions: [apply()])
    }
    
    fileprivate func cancelButton() -> ViewContainer<ButtonSheetView> {
        let cancelString = NSLocalizedString("Cancel", comment: "")
        return  ViewContainer<ButtonSheetView>(item: .default(title: cancelString), actions: [cancel()])
    }
    
    fileprivate func deleteContactButton() -> ViewContainer<ButtonSheetView> {
        let deleteContactString = NSLocalizedString("Delete\ncontact", comment: "")
        return  ViewContainer<ButtonSheetView>(item: .destructive(title: deleteContactString), actions: [delete()])
    }
    
    fileprivate func shareContactButton() -> ViewContainer<ButtonSheetView> {
        let shareContactString = NSLocalizedString("Share\ncontact", comment: "")
        return  ViewContainer<ButtonSheetView>(item: .default(title: shareContactString), actions: [cancel()])
    }
    
    @IBAction func addContactPhoto(_ sender: UIButton) {
        showPicker()
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let img = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        if let data = UIImageJPEGRepresentation(img, 1.0) as Data? {
            viewModel.photo = data
            photoImageView.image = UIImage(data: data)
            showChangeAvatarButton(false)
        }
        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Configure 
extension ContactCardViewController {
    func configureAvatar() {
        guard let avatarData = viewModel.contact.avatarData else {
            showChangeAvatarButton(true)
            return
        }
        showChangeAvatarButton(false)
        avatarImageView.image = UIImage(data: avatarData)
    }
}

// MARK: - ContactVMDelegate
extension ContactCardViewController: ContactCardVMDelegate {
    
    func showChangeAvatarButton(_ show: Bool) {
        view.bringSubview(toFront: photoButton)
        photoButton.isHidden = !show
        addPhotoLabel.isHidden = !show
    }
}
