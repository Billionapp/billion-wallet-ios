//
//  ScanViewController.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 08/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class ScanViewController: BaseViewController<ScanVM>, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var flashButton: UIButton?
    @IBOutlet private weak var gradientView: RadialGradientView?
    @IBOutlet private weak var aimView: UIView?
    @IBOutlet weak var extractButton: UIButton!
    
    var pickModalView: PickImageModalView?
    var imagePicker: UIImagePickerController?
    override func configure(viewModel: ScanVM) {
        viewModel.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aimView?.layer.borderColor = UIColor.white.cgColor
        viewModel.scanQrCode(view: self.view, rectOfInterest: (aimView?.frame)!)
        viewModel.getPhotos()
        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        hideExtractButton()
    }
    
    
    func handleError(error: String) {
        showPopup(type: .cancel, title: error)
    }
    
    //MARK: Actions
    @IBAction func closeAction() {
        navigationController?.pop()
    }
    
    @IBAction func flashAction() {
        viewModel.toggleFlash()
    }
    
    @IBAction func extractQrFromImageAction() {
        pickModalView = PickImageModalView.init(viewModel: viewModel, controller: self)
        UIApplication.shared.keyWindow?.addSubview(pickModalView!)
    }
    
    func pickFromGalleryActionWithoutEditing() {
        self.present(imagePicker!, animated: false, completion: nil)
    }
    
    //Need to hide button if lower then iOS 11. CIDetector bug.
    fileprivate func hideExtractButton() {
        guard #available(iOS 11, *) else {
            extractButton.isHidden = true
            return
        }
    }
    
    //MARK: ImagePicker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            viewModel.pickedImage = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ScanViewController: ScanVMDelegate {
    
    // MARK: Delegates binding
    func codeDidFound(code: String) {
        if pickModalView != nil {
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
