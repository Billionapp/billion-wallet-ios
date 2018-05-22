//
//  ScanViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import Photos

class ScanViewController: BaseViewController<ScanVM>, UIImagePickerControllerDelegate {
    
    typealias LocalizedStrings = Strings.Scan
    
    @IBOutlet weak var flashButton: UIButton?
    @IBOutlet private weak var gradientView: RadialGradientView!
    @IBOutlet private weak var aimView: UIView!
    @IBOutlet weak var extractButton: UIButton!
    @IBOutlet weak var extractHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var extractBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var flashBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressAlertLabel: UILabel!
    
    var pickModalView: PickImageModalView?
    var imagePicker: UIImagePickerController?
    let permissionAlert = PermissionAlert()
    weak var mainRouter: MainRouter?
    
    private var titledView: TitledView!
    
    override func configure(viewModel: ScanVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        localize()
        aimState(true, labelText: "")
        
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        
        hideExtractButton()
        setupLayout()
        setupTitledView()
        viewModel.scanQrCode(view: view, rectOfInterest: aimView.frame)
    }
    
    private func setupTitledView() {
        titledView = TitledView()
        titledView.title = LocalizedStrings.title
        titledView.subtitle = LocalizedStrings.directionHint
        titledView.closePressed = {
            self.navigationController?.pop()
        }
        view.addSubview(titledView)
    }
    
    private func localize() {
        extractButton.setTitle(LocalizedStrings.extractButton, for: .normal)
    }
    
    private func setupLayout() {
        extractBottomConstraint.constant = Layout.model.offset
        extractHeightConstraint.constant = Layout.model.height
        flashBottomConstraint.constant = Layout.model.spacing
        extractButton.layer.standardCornerRadius()
    }
    
    private func showGallery() {
        self.viewModel.getPhotos()
        self.pickModalView = PickImageModalView.init(viewModel: self.viewModel, controller: self)
        UIApplication.shared.keyWindow?.addSubview(self.pickModalView!)
    }
    
    func handleError(error: String) {
        if (imagePicker?.isViewLoaded)! {
            imagePicker?.dismiss(animated: false) {
                self.aimView.isHidden = true
                let popup = PopupView(type: .cancel, labelString: error)
                popup.delegate = self
                UIApplication.shared.keyWindow?.addSubview(popup)
            }
        } else {
            showPopup(type: .cancel, title: error)
        }
    }
    
    // MARK: Actions
    
    @IBAction func flashAction() {
        viewModel.toggleFlash()
    }
    
    @IBAction func extractQrFromImageAction() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized: showGallery()
        case .notDetermined:
                PHPhotoLibrary.requestAuthorization({status in
                    if status == .authorized {
                        self.showGallery()
                    }
                })
        case .denied:
            let alert = permissionAlert.requestPermission(with: LocalizedStrings.libraryAccessErrorFormat, cancelHandler: nil)
            present(alert, animated: true, completion: nil)
        default: break
        }
    }
    
    func pickFromGalleryActionWithoutEditing() {
        self.present(imagePicker!, animated: false, completion: nil)
    }
    
    // Need to hide button if lower then iOS 11. CIDetector bug.
    private func hideExtractButton() {
        guard #available(iOS 11, *) else {
            extractButton.isHidden = true
            return
        }
    }
    
    // MARK: ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
           viewModel.pickedImage = pickedImage
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
}

extension ScanViewController: PopupViewDelegate {
    func viewDidDismiss() {
        self.aimView.isHidden = false
    }
}

extension ScanViewController: ScanVMDelegate {
    
    func cameraAccessDenied() {
        let alert = permissionAlert.requestPermission(with: LocalizedStrings.cameraAccessErrorFormat) { [weak self] (cancel) in
            self?.navigationController?.pop()
        }
        
        present(alert, animated: true, completion: nil)
    }

    func billionCodeDidFound() {
        if pickModalView != nil {
            pickModalView?.close()
        }
        mainRouter?.rollbackToContactList()
    }
    
    func resetScan() {
        aimState(true, labelText: "")
    }
    
    func scanWrongSource(with failure: String) {
        aimState(false, labelText: failure)
    }
    
    func aimState( _ isPositive: Bool, labelText: String ) {
        let color = isPositive ? UIColor.white.cgColor : UIColor.red.cgColor
        aimView?.layer.borderColor = color
        addressAlertLabel.text = isPositive ? "" : labelText
    }
    
    // MARK: Delegates binding
    func codeFound() {
        if pickModalView != nil {
            dismiss(animated: false, completion: nil)
            pickModalView?.close()
        }
        navigationController?.pop()
    }
    
    func torchWasToggled(torchOn: Bool) {
        if torchOn {
            self.flashButton?.setImage(UIImage(named: "Flash"), for: .normal)
        } else {
            self.flashButton?.setImage(UIImage(named: "FlashOff"), for: .normal)
        }
    }
}
