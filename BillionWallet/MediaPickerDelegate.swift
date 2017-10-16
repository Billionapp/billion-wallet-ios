//
//  MediaPickerDelegate.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol MediaPickerDelegate {
    var imagePicker: ImagePicker { get set }
    func presentMediaPicker(fromController controller: UIViewController, sourceType: UIImagePickerControllerSourceType)
    func didSelectFromMediaPicker(withImage image: UIImage)
    func didSelectFromMediaPicker(withMediaUrl mediaUrl: NSURL)
}

extension MediaPickerDelegate {
    
    func presentMediaPicker(fromController controller: UIViewController, sourceType: UIImagePickerControllerSourceType) {
        imagePicker.delegate = self
        controller.present(imagePicker.picker, animated: true, completion: nil)
    }
    
    func didSelectFromMediaPicker(withMediaUrl mediaUrl: NSURL) {
        
    }
}
