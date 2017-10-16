//
//  AddContactAddressViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AddContactAddressViewController: BaseViewController<AddContactAddressVM>, UIImagePickerControllerDelegate {
    
    weak var router: MainRouter?
    
    fileprivate var dataManager: StackViewDataManager!
    fileprivate var titledView: TitledView!
    fileprivate var menuStackView: MenuStackView!
    fileprivate let picker = UIImagePickerController()
    fileprivate var gradientView: UIView!
    
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var photoButton: UIButton!
    @IBOutlet weak var photoImageView: UIImageView!
    
    override func configure(viewModel: AddContactAddressVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        photoImageView.addBlackGradientLayer()
        setupMenuStackView()
        show()
        hideTips(false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private methods
    
    fileprivate func setupMenuStackView() {
        titledView = TitledView()
        titledView.title = NSLocalizedString("Add contact", comment: "")
        titledView.subtitle = NSLocalizedString("Enter a nickname to add a new one. Contact. Adding is done using data exchange through the server.", comment: "")
        titledView.closePressed = { [weak self] in
            self?.switchToContactList()
        }
        view.addSubview(titledView)
        
        menuStackView = MenuStackView()
        view.addSubview(menuStackView)
        
        dataManager = StackViewDataManager(stackView: menuStackView.stackView)
    }
    
    fileprivate func show() {
        dataManager.clear()
        
        let address = NSLocalizedString("Address:", comment: "")
        let name = NSLocalizedString("Name:", comment: "")
        let enterAddress = NSLocalizedString("Enter address", comment: "")
        let enterName = NSLocalizedString("Enter name", comment: "")
        let cancel = NSLocalizedString("Cancel", comment: "")
        let ok = NSLocalizedString("OK", comment: "")
        let text = viewModel.newContactAddress ?? ""
        
        dataManager.append(containers: [
            ViewContainer<SectionView>(item: [
                ViewContainer<ColumnsView>(item: ([
                    ViewContainer<LabelView>(item: .defails(text: address, width: 75)),
                    ViewContainer<InputSheetView>(item: (placeholder: enterAddress, text: text, editable: true), actions: [addressChanged()]),
                    ], .fill)),
                ViewContainer<ColumnsView>(item: ([
                    ViewContainer<LabelView>(item: .defails(text: name, width: 75)),
                    ViewContainer<InputSheetView>(item: (placeholder: enterName, text: nil, editable: true), actions: [nameChanged()])
                    ], .fill))
                ]),
            
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
    @IBAction func addContactPhoto(_ sender: UIButton) {
        showPicker()
    }
    
    fileprivate func cancelAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] _ in
            self?.viewModel.newContactName = nil
            self?.viewModel.newContactName = nil
            self?.navigationController?.pop()
        }
    }
    
    fileprivate func okAction() -> ViewContainerAction<ButtonSheetView> {
        return ViewContainerAction<ButtonSheetView>(.click) { [weak self] _ in
            guard let this = self else { return }
            guard let _ = this.viewModel.newContactName else {
                self?.view.endEditing(true)
                let popup = PopupView(type: .cancel, labelString: "Please, enter contact name.")
                UIApplication.shared.keyWindow?.addSubview(popup)
                return
            }
            
            guard let _ = this.viewModel.newContactAddress else {
                self?.view.endEditing(true)
                let popup = PopupView(type: .cancel, labelString: "Please, enter contact address.")
                UIApplication.shared.keyWindow?.addSubview(popup)
                return
            }
            
            if !(this.viewModel.newContactAddress?.isValidBitcoinAddress)! && ((try? PaymentCode(with: this.viewModel.newContactAddress!)) == nil) {
                self?.view.endEditing(true)
                let popup = PopupView(type: .cancel, labelString: "Please, enter valid bitcoin address.")
                UIApplication.shared.keyWindow?.addSubview(popup)
                return
            }
            
            do {
                try this.viewModel.createContact()
            } catch {
                self?.view.endEditing(true)
                let popup = PopupView(type: .cancel, labelString: "Error adding contact")
                UIApplication.shared.keyWindow?.addSubview(popup)
            }
        }
    }
    
    fileprivate func addressChanged() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.change) { [weak self] data in
            guard let address = data.userInfo?["text"] as? String else { return }
            self?.viewModel.newContactAddress = address
        }
    }
    
    fileprivate func nameChanged() -> ViewContainerAction<InputSheetView> {
        return ViewContainerAction<InputSheetView>(.change) { [weak self] data in
            guard let name = data.userInfo?["text"] as? String else { return }
            self?.viewModel.newContactName = name
        }
    }
    
    fileprivate func switchToContactList() {
        guard let controllers = navigationController?.viewControllers else {return}
        if let destinationVc = controllers.filter({$0 is ContactsViewController}).first {
            navigationController?.popToViewController(destinationVc, animated: true)
        } else {
            router?.navigationController.popToRootViewController(animated: false)
            let image = captureScreen(view: view)
            router?.showContactsView(output: nil, mode: .default, back: image)
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let img = info[UIImagePickerControllerOriginalImage] as! UIImage
        if let data = UIImageJPEGRepresentation(img, 1.0) as Data? {
            viewModel.photo = data
            photoImageView.image = UIImage(data: data)
            hideTips(true)
        }
        
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

// MARK: - AddContactAddressVMDelegate
extension AddContactAddressViewController: AddContactAddressVMDelegate {
    func contactAdded() {
        self.switchToContactList()
    }
}

//MARK: - Configures 
extension AddContactAddressViewController {
    func showPicker() {
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    func hideTips(_ hide: Bool) {
        photoButton.isHidden = hide
        photoImageView.isHidden = !hide
        addPhotoLabel.isHidden = hide
    }
}
