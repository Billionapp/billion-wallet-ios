//
//  AddContactCardViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 19/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit


class AddContactCardViewController: BaseViewController<AddContactCardVM>, UITextFieldDelegate {
    
    typealias LocalizedString = Strings.AddContactCard
    
    weak var router: MainRouter?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var contactTypeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addContactButton: UIButton!
    @IBOutlet weak var blackGradientView: UIView!
    
    override func configure(viewModel: AddContactCardVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter name...", attributes: attributes)
        nameTextField.enablesReturnKeyAutomatically = true
        viewModel.getContact()
        configureGradient()
        localize()
        testnetLabel()
    }
    
    // MARK: - Privates
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
            let labelFrame = CGRect(x: 20, y: nameTextField.frame.origin.y + 20, width: UIScreen.main.bounds.width - 40, height: 130)
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
    
    // MARK: - Actions
    @IBAction func addContactPressed(_ sender: UIButton) {
        finishCardAdding()
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        navigationController?.popToGeneralView()
    }
    
    @IBAction func didChangeName(_ sender: UITextField) {
        guard let text = sender.text else { return }
        viewModel.didChangeName(name: text)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        finishCardAdding()
        return true
    }
    
    private func finishCardAdding() {
        view.endEditing(true)
        viewModel.save()
        router?.popAddContactCard()
    }
    
    private func localize() {
        addContactButton.setTitle(LocalizedString.addContact, for: .normal)
    }
    
}

// MARK: - AddContactCardVMDelegate

extension AddContactCardViewController: AddContactCardVMDelegate {
    
    func didReceiveContact(_ contact: ContactProtocol) {
        let avatarImage = contact.avatarImage
        avatarImageView.image = avatarImage
        backgroundImageView.image = avatarImage
        nameLabel.text = contact.displayName
        nameTextField.text = contact.givenName
        qrImageView.image = contact.qrImage
        addressLabel.text = contact.uniqueValue
    }
    
}

