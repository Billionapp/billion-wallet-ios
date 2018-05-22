//
//  Strings+Scan.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum Scan {

        static let title = NSLocalizedString("Scan.title", tableName: "Scan", value: "Scan", comment: "Scan title")
        static let extractButton = NSLocalizedString("Scan.extractButton", tableName: "Scan", value: "Extract  QR-code\nfrom  picture", comment: "Extract QR code from picture button title")
        static let incorrectPC = NSLocalizedString("Scan.Notice.incorrectPC", tableName: "Scan", value: "This is not a Billion code", comment: "label shown that image which user scaned")
        static let directionHint = NSLocalizedString("Scan.directionHint", tableName: "Scan", value: "Scan the QR", comment: "Scan the QR title")
        static let cameraAccessErrorFormat = NSLocalizedString("Scan.Notice.cameraAccessError", tableName: "Scan", value: "Billion is not allowed to access the camera. Please allow camera access in Settings.", comment: "Label shown that user need to allow access to to camera in Settings")
        static let libraryAccessErrorFormat = NSLocalizedString("Scan.Notice.photoLibrary", tableName: "Scan", value: "Billion is not allowed to access the photo library. Please allow access to photos in Settings.", comment: "Label shown that user need to allow access to to photo library in Settings")
        static let selfPC = NSLocalizedString("Scan.Notice.selfPC", tableName: "Scan", value: "This is your own Billion code", comment: "Label mean that user scaned his own Billion code")
        static let invalidQr = NSLocalizedString("Scan.Notice.invalidQr", tableName: "Scan", value: "Invalid QR code", comment: "Invalid QR code title")
        static let selfAddress = NSLocalizedString("Scan.Notice.selfAddress", tableName: "Scan", value: "This is your own address", comment: "This is your own address title")
        static let galeryButton = NSLocalizedString("Scan.galeryButton", tableName: "Scan", value: "Go to Gallery", comment: "Open iOS Gallery app to select photo")
        static let cancelButton = NSLocalizedString("Scan.cancelButton", tableName: "Scan", value: "Cancel", comment: "Cancel button title")
        
        /* Alert actions */
        static let permissionRequired = NSLocalizedString("Scan.Notice.permissionRequired", tableName: "Scan", value: "Permission required", comment: "Label shown that app need some permission in setting of device")
        static let openSetting = NSLocalizedString("Scan.Notice.openSettings", tableName: "Scan", value: "Settings", comment: "Settings")
        static let cancel = NSLocalizedString("Scan.Notice.cancel", tableName: "Scan", value: "Cancel", comment: "Cancel")
        
        static let extractQRTitle = NSLocalizedString("Scan.title.extractQR", tableName: "Scan", value: "Extract QR-code", comment: "Extract QR-code title")
        static let selectImageWithQR = NSLocalizedString("Scan.subtitle.selectImageWithQR", tableName: "Scan", value: "Select an image with QR-code", comment: "Select an image with QR-code title")
    }
}
