//
//  SetupCardViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

class SetupCardViewController: BaseViewController<SetupCardVM>, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    weak var router: MainRouter?
    typealias LocalizedString = Strings.SetupCard
    
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var selectionSubtitle: UILabel!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profileSubtitle: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileQR: UIImageView!
    @IBOutlet weak var pcTitle: UILabel!
    @IBOutlet weak var pcLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var textFieldBottom: UIView!
    @IBOutlet weak var avatarCollection: UICollectionView!
    @IBOutlet weak var gotoGaleryButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    var nameTextFieldCenterY: CGFloat!
    var nameLabelCenterY: CGFloat!
    var textFeildBottomCenterY: CGFloat!
    
    fileprivate let picker = UIImagePickerController()
    
    override func configure(viewModel: SetupCardVM) {
        super.configure(viewModel: viewModel)
        viewModel.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setBack()
        setTitles()
        setCollection()
        setDelegates()
        removeSwipeDownGesture()
        setupKeyboardNotifications()
        backupFrames()
        if viewModel.avatar != nil {
            profileImage.image = viewModel.avatar
            nameTextField.text = viewModel.name ?? ""
            showCardSimple()
        } else {
            animateStart()
        }
    }
    
    private func backupFrames() {
        nameTextFieldCenterY = nameTextField.center.y
        nameLabelCenterY = nameLabel.center.y
        textFeildBottomCenterY = textFieldBottom.center.y
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    @objc func keyboardDidChangeFrame(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let height = keyboardRectangle.height

            UIView.animate(withDuration: 0.3, animations: {
                if Layout.model.emojiKeybordHeight == height {
                    let keyboardDiff = Layout.model.emojiKeybordHeight - Layout.model.keyboardHeight
                    self.nameLabel.center.y = self.nameLabelCenterY - keyboardDiff
                    self.nameTextField.center.y = self.nameTextFieldCenterY - keyboardDiff
                    self.textFieldBottom.center.y = self.textFeildBottomCenterY - keyboardDiff
                } else {
                    self.nameLabel.center.y = self.nameLabelCenterY
                    self.nameTextField.center.y = self.nameTextFieldCenterY
                    self.textFieldBottom.center.y = self.textFeildBottomCenterY
                }
            })
            
            if Layout.model.emojiKeybordHeight == height {
                if pcTitle.isHidden && pcLabel.isHidden {
                    return
                }
                let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromTop]
                UIView.transition(with: pcLabel, duration: 0.3, options: transitionOptions, animations: {
                    self.pcTitle.isHidden = true
                    self.pcLabel.isHidden = true
                })
            } else {
                if !pcTitle.isHidden && !pcLabel.isHidden {
                    return
                }
                let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromBottom]
                UIView.transition(with: pcLabel, duration: 0.3, options: transitionOptions, animations: {
                    self.pcTitle.isHidden = false
                    self.pcLabel.isHidden = false
                })
            }
            
            
        }
    }
    
    private func animateStart() {
        let originFrame = selectionView.frame
        selectionView.frame.origin.x = UIScreen.main.bounds.width
        UIView.animate(withDuration: 0.4,
                       delay: 0.2,
                       usingSpringWithDamping: 0.65,
                       initialSpringVelocity: 0.5,
                       options: .curveLinear,
        animations: {
            self.selectionView.frame.origin.x = originFrame.origin.x
        }) { _ in
            //
        }
    }
    
    private func setDelegates() {
        nameTextField.delegate = self
        picker.delegate = self
    }
    
    private func setCollection() {
        avatarCollection.register(UINib(nibName: "SetupAvatarCell".nibNameForCell(), bundle: nil), forCellWithReuseIdentifier: "SetupAvatarCell")
        avatarCollection.dataSource = viewModel
        avatarCollection.delegate = viewModel
    }
    
    private func setBack() {
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame = selectionView.bounds
        gradient.colors = [Color.buttonTop.cgColor, Color.buttonBottom.cgColor]
        selectionView.layer.insertSublayer(gradient, at: 0)
        selectionView.layer.cornerRadius = Layout.model.cornerRadius
        selectionView.layer.masksToBounds = true
        profileView.layer.cornerRadius = Layout.model.cornerRadius
        profileView.layer.masksToBounds = true
        profileImage.layer.cornerRadius = 10
        profileImage.layer.masksToBounds = true
        profileQR.layer.cornerRadius = 10
        profileQR.layer.masksToBounds = true
    }
    
    private func setTitles() {
        header.text = LocalizedString.header
        selectionSubtitle.text = LocalizedString.selectionSubtitle
        profileSubtitle.text = LocalizedString.profileSubtitle
        pcTitle.text = LocalizedString.pcTitle
        pcLabel.text = viewModel.paymentCodeString
        nameLabel.text = LocalizedString.nameLabel
        profileQR.image = createQRFromString(viewModel.paymentCodeString, size: profileQR.frame.size, inverseColor: true)
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        nameTextField.attributedPlaceholder = NSAttributedString(string: LocalizedString.placeholder, attributes: attributes)
        gotoGaleryButton.setTitle(LocalizedString.gotoGaleryButton, for: .normal)
        cameraButton.setTitle(LocalizedString.cameraOpenButton, for: .normal)
        startButton.setTitle(LocalizedString.startButton, for: .normal)
        startButton.isHidden = true
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = gotoGaleryButton.bounds
        gradient.colors = [Color.buttonTopSelected.cgColor, Color.buttonBottomSelected.cgColor]
        gotoGaleryButton.setBackgroundImage(viewModel.imageWithLayer(layer: gradient), for: .highlighted)
        cameraButton.setBackgroundImage(viewModel.imageWithLayer(layer: gradient), for: .highlighted)
    }
    
    private func showCard(frame: CGRect) {
        viewModel.uploadAvatar(avatar: viewModel.selectedImage!)
        profileImage.image = viewModel.selectedImage
        let originImageFrame = profileImage.frame
        let cellFrame = avatarCollection.convert(frame, to: selectionView)
        profileImage.frame = cellFrame
        profileImage.alpha = 1
        avatarCollection.reloadData()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.selectionSubtitle.alpha = 0
            self.profileSubtitle.alpha = 1
            self.avatarCollection.frame.origin.x = UIScreen.main.bounds.width
            self.selectionView.frame.size.height = self.selectionView.frame.size.height - 67
            self.profileView.frame.size.height = self.profileView.frame.size.height - 67
            self.gotoGaleryButton.alpha = 0
            self.separatorView.alpha = 0
            self.cameraButton.alpha = 0
            self.profileImage.frame = originImageFrame
            self.pcTitle.alpha = 1
            self.pcLabel.alpha = 1
            self.nameLabel.alpha = 1
            self.nameTextField.alpha = 1
            self.textFieldBottom.alpha = 1
            self.nameTextField.becomeFirstResponder()
        }) { _ in
            UIView.animate(withDuration: 0.15, animations: {
                self.profileView.alpha = 1
                self.profileQR.alpha = 1
            })
        }
    }
    
    private func showCardSimple() {
        self.selectionSubtitle.alpha = 0
        self.profileSubtitle.alpha = 1
        self.avatarCollection.alpha = 0
        self.selectionView.frame.size.height = self.selectionView.frame.size.height - 67
        self.profileView.frame.size.height = self.profileView.frame.size.height - 67
        self.gotoGaleryButton.alpha = 0
        self.separatorView.alpha = 0
        self.cameraButton.alpha = 0
        self.pcTitle.alpha = 1
        self.pcLabel.alpha = 1
        self.nameLabel.alpha = 1
        self.nameTextField.alpha = 1
        self.textFieldBottom.alpha = 1
        self.profileView.alpha = 1
        self.profileQR.alpha = 1
        self.profileImage.alpha = 1
        self.nameTextField.becomeFirstResponder()
    }
    
    @IBAction func pickFromCamera() {
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func pickFromGallery() {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func start() {
        UIView.animate(withDuration: 0.2, animations: {
            self.startButton.frame.origin.y = UIScreen.main.bounds.height
            self.selectionView.frame = self.startButton.frame
        }) { _ in
            self.router?.showStartScreen()
        }
    }
    
    // MARK: UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var cropImage: UIImage
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            cropImage = image.resizeTo(newSize: CGSize(width: 80, height: 80))
            viewModel.uploadAvatar(avatar: cropImage)
            view.endEditing(true)
            profileImage.image = cropImage
            showCardSimple()
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextFieldViewDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let name = textField.text {
            viewModel.uploadName(name: name)
        }
        textField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText: NSString = (textField.text ?? "") as NSString
        self.header.text = textFieldText.replacingCharacters(in: range, with: string)
        return true
    }
}

//MARK: SetupCardVMDelegate
extension SetupCardViewController: SetupCardVMDelegate {
    func didPickImage(frame: CGRect) {
        showCard(frame: frame)
    }
    
    func didFinishSetup() {
        self.nameTextField.resignFirstResponder()
        self.startButton.isHidden = false
    }
}
