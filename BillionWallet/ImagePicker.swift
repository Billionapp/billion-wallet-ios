//
//  ImagePicker.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit
import MobileCoreServices

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var delegate: MediaPickerDelegate?
    let sourceType: UIImagePickerControllerSourceType
    let picker = UIImagePickerController()
    
    init(sourceType: UIImagePickerControllerSourceType) {
        self.sourceType = sourceType
        super.init()
        self.picker.allowsEditing = true
        self.picker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            switch mediaType {
            case String(kUTTypeImage):
                if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                    self.delegate?.didSelectFromMediaPicker(withImage: selectedImage)
                }
            case String(kUTTypeImage), String(kUTTypeMovie), String(kUTTypeVideo):
                if let selectedMediaURL = info[UIImagePickerControllerMediaURL] as? NSURL {
                    self.delegate?.didSelectFromMediaPicker(withMediaUrl: selectedMediaURL)
                }
            default:
                break
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
