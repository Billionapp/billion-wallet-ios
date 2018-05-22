//
//  ProfileViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ProfileViewController: BaseViewController<ProfileVM>, UIImagePickerControllerDelegate, UITextFieldDelegate {

    typealias LocalizedStrings = Strings.Profile
    
    weak var router: MainRouter?
    fileprivate let picker = UIImagePickerController()
    fileprivate var textfieldBottomConstraintDefault: CGFloat = 0
    
    @IBOutlet weak var blackGradientView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var contactTypeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var tapEmptyGesture: UITapGestureRecognizer!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var sharingBackView: UIView!
    @IBOutlet weak var shareSelfView: UIImageView!
    @IBOutlet weak var selfNameLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    override func configure(viewModel: ProfileVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        nameTextField.attributedPlaceholder = NSAttributedString(string: LocalizedStrings.enterNick, attributes: attributes)
        picker.delegate = self
        nameTextField.enablesReturnKeyAutomatically = true
        viewModel.getUserData()
        nameTextField.autocapitalizationType = .words
        tapGesture.addTarget(self, action: #selector(self.copyPaymentCode))
        tapEmptyGesture.addTarget(self, action: #selector(self.closeButtonPressed(_:)))
        configureGradient()
        configureBorders()
        localize()
        testnetLabel()
    }
    
    // MARK: - Private methods
    
    private func localize() {
        selfNameLabel.text = LocalizedStrings.name
    }

    @objc func copyPaymentCode() {
        let pcString = viewModel.paymentCodeString
        UIPasteboard.general.string = pcString
        let popup = PopupView(type: .ok, labelString: LocalizedStrings.pcCopied)
        UIApplication.shared.keyWindow?.addSubview(popup)
    }
    
    @IBAction func addContactPhoto(_ sender: UIButton) {
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        navigationController?.pop()
    }
    
    @IBAction func didChangeName(_ sender: UITextField) {
        guard let text = sender.text else { return }
        viewModel.setName(to: text)
    }
    
    @IBAction func shareContactPressed(_ sender: UIButton) {
        prepareScreenForSharing(true)
        let cardImage = UIImage.init(view: self.view)
        prepareScreenForSharing(false)
        viewModel.shareContact(card: cardImage)
    }
    
    private func prepareScreenForSharing(_ isSharing: Bool) {
        sharingBackView.isHidden = !isSharing
        shareSelfView.isHidden = isSharing
        selfNameLabel.isHidden = isSharing
        nameTextField.isHidden = isSharing
        separatorView.isHidden = isSharing
    }
    
    private func configureBorders() {
        borderView.layer.borderWidth = 6
        borderView.layer.borderColor = UIColor.white.cgColor
    }
    
    private func configureGradient() {
        let startColor = Color.ProfileCardGradient.startColor
        let endColor: UIColor = Color.ProfileCardGradient.endColor
        let endcolorWithAlpha = endColor.withAlphaComponent(1)
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = blackGradientView.bounds
        gradient.colors = [startColor.cgColor, endcolorWithAlpha.cgColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.zPosition = -1
        blackGradientView.layer.addSublayer(gradient)
    }
    
    private func testnetLabel() {
        #if BITCOIN_TESTNET
            let labelFrame = CGRect(x: 20, y: nameTextField.frame.origin.y + 100, width: UIScreen.main.bounds.width - 40, height: 130)
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
    
    // MARK: UITextFieldViewDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        viewModel.save()
        return true
    }
    
    // MARK: UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        let cropImage = image.resizeTo(newSize: CGSize(width: 80, height: 80))
        viewModel.setPhoto(to: cropImage.tuneCompress())
        view.endEditing(true)
        viewModel.save()
        avatarImageView.image = cropImage
        backgroundImageView.image = cropImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
   
}

// MARK: - ProfileVMDelegate

extension ProfileViewController: ProfileVMDelegate {
    
    func didReceiveUserData(_ userData: LocalUserData?) {
        if let avatarImage = userData?.imageData {
            DispatchQueue.global().async {
                let image = UIImage(data: avatarImage)
                DispatchQueue.main.async { [weak self] in
                    self?.avatarImageView.image = image
                    self?.backgroundImageView.image = image
                }
            }

        } else {
            avatarImageView.image = #imageLiteral(resourceName: "photo_placeholder")
            backgroundImageView.image = nil
        }
        nameLabel.text = userData?.name
        nameTextField.text = userData?.name
        qrImageView.image = viewModel.getPaymentCodeQRImage()
        addressLabel.text = viewModel.paymentCodeString
        contactTypeLabel.text = LocalizedStrings.paymentCodeString
    }
    
    func closeView() {
        navigationController?.pop()
    }
    
    func didReceiveSharePicture(card: UIImage) {
        let controller = UIActivityViewController(activityItems: [card as Any], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
    }    
}

private extension UIImage{
    convenience init(view: UIView) {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
        
    }
}
