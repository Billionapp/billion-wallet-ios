//
//  ContactCardViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 30.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ContactCardViewController: BaseViewController<ContactCardVM>, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    typealias LocalizedStrings = Strings.ContactCard
    
    private let picker = UIImagePickerController()
    private var textfieldBottomConstraintDefault: CGFloat = 0
    
    @IBOutlet private weak var boarderView: UIView!
    @IBOutlet private weak var backgroundImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var qrImageView: UIImageView!
    @IBOutlet private weak var contactTypeLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var shareContactButton: UIButton!
    @IBOutlet private weak var sharingBackView: UIView!
    @IBOutlet private weak var blackGradientView: UIView!
    @IBOutlet private var loader: UIActivityIndicatorView!
    
    weak var router: MainRouter?
    
    override func configure(viewModel: ContactCardVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        nameTextField.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.namePlaceholder, attributes: attributes)
        picker.delegate = self
        nameTextField.enablesReturnKeyAutomatically = true
        viewModel.getContact()
        nameTextField.autocapitalizationType = .words
        configureBorders()
        configureGradient()
        testnetLabel()
        setupLoader()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    private func configureBorders() {
        boarderView.layer.borderWidth = 6
        boarderView.layer.borderColor = UIColor.white.cgColor
    }
    
    private func configureGradient() {
        let startColor = Color.ProfileCardGradient.startColor
        let endColor: UIColor = Color.ProfileCardGradient.endColor
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = blackGradientView.bounds
        gradient.colors = [startColor.cgColor, endColor.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.zPosition = -1
        blackGradientView.layer.addSublayer(gradient)
    }
    
    private func testnetLabel() {
        #if BITCOIN_TESTNET
        let labelFrame = CGRect(x: 20, y: nameTextField.frame.origin.y + 30, width: UIScreen.main.bounds.width - 40, height: 130)
        let label = UILabel.init(frame: labelFrame)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.text = Strings.OtherErrors.testnetWarning
        label.font = UIFont.systemFont(ofSize: 80, weight: .bold)
        label.textColor = UIColor.red
        view.addSubview(label)
        #endif
    }
    
    private func setupLoader() {
        self.loader = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.loader.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.addSubview(self.loader)
        self.loader.hidesWhenStopped = true
        NSLayoutConstraint.activate([
            self.loader.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            self.loader.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
            ])
    }

    // MARK: - Actions
    @IBAction func deleteAction(_ sender: UIButton) {
        let back = captureScreen(view: view)
        let confirmView = ConfirmDeletingView(backView: back)
        confirmView.delegate = self
        UIApplication.shared.keyWindow?.addSubview(confirmView)
    }
    
    @IBAction func addContactPhoto(_ sender: UIButton) {
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func shareContactPressed(_ sender: UIButton) {
        sharingBackView.isHidden = false
        if let cardImage = self.view.makeSnapshot(immediately: false) {
            sharingBackView.isHidden = true
            viewModel.shareContact(card: cardImage)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        navigationController?.pop()
    }
    
    @IBAction func didChangeName(_ sender: UITextField) {
        guard let text = sender.text else { return }
        viewModel.didChangeName(name: text)
    }
    
    @IBAction func refreshContactCard(_ sender: Any) {
        viewModel.refreshContact()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        viewModel.save()
        return true
    }
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let cropImage = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        viewModel.didChangePhoto(photo: cropImage)
        avatarImageView.image = cropImage
        backgroundImageView.image = cropImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - ConfirmViewDelegate
extension ContactCardViewController: ConfirmDeletingViewDelegate {
    func contactDeleted() {
        viewModel.archiveContact()
    }
}

// MARK: - ContactCardVMDelegate
extension ContactCardViewController: ContactCardVMDelegate {
    func startLoader() {
        DispatchQueue.main.async {
            self.loader.startAnimating()
        }
    }
    
    func stopLoader() {
        DispatchQueue.main.async {
            self.loader.stopAnimating()
        }
    }
    
    func didReceiveSharePicture(_ sharePic: UIImage) {
        let controller = UIActivityViewController(activityItems: [sharePic as Any, viewModel.urlToShare], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }
    
    func didReceiveContact(_ contact: ContactProtocol) {
        let avatarImage = contact.avatarImage
        self.avatarImageView.image = avatarImage
        self.backgroundImageView.image = avatarImage
        self.nameLabel.text = contact.displayName
        self.nameTextField.text = contact.givenName
        self.qrImageView.image = contact.qrImage
        self.addressLabel.text = contact.uniqueValue
        self.contactTypeLabel.text = contact.description.value
    }
    
    func didDelete() {
        navigationController?.pop()
    }
}
