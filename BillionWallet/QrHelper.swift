//
//  QrHelper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 03/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

func createQRFromString(_ str: String, size: CGSize, inverseColor: Bool = false) -> UIImage? {
    let data = str.data(using: String.Encoding.utf8)
    if let filter = CIFilter(name: "CIQRCodeGenerator") {
        guard let colorFilter = CIFilter(name: "CIFalseColor") else { return nil }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("L", forKey: "inputCorrectionLevel")
        
        colorFilter.setValue(filter.outputImage, forKey: "inputImage")
        
        if inverseColor {
            colorFilter.setValue(CIColor.clear, forKey: "inputColor1")
            colorFilter.setValue(CIColor.white, forKey: "inputColor0")
        }
        
        guard let qrCodeImage = colorFilter.outputImage else {
            return nil
        }

        let scaleX = size.width / qrCodeImage.extent.size.width
        let scaleY = size.height / qrCodeImage.extent.size.height
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        
        if let output = filter.outputImage?.transformed(by: transform) {
            guard let filteredImage = reduceBrightness(ciImage: output) else {return nil}
            return filteredImage
        }
    }
    return nil
}



func performQRCodeDetection(image: CIImage, success: (String) -> Void, failure: (String) -> Void) {
    var detector: CIDetector?
    let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: options)!
    var decode = ""
    if let det = detector  {
        let features = det.features(in: image) as! [CIQRCodeFeature]
        if features.count == 0 {
            failure("Photo does not contain QRcode")
        } else {
            for feature in features {
                decode = feature.messageString!
            }
            if let address = confirmBitcoinAddress(str: decode) {
                success(address)
            } else if let pc = try? PaymentCode.init(with: decode) {
                success(pc.serializedString)
            } else {
                failure("It's not a bitcoin address")
            }
        }
    }
}

func confirmBitcoinAddress(str: String) -> String? {
    var address = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    if let url = NSURL.init(string: address as String) {
        if url.scheme == "bitcoin" {
            if let host = url.host {
                address = host
            }
        }
    }
    
    if address.isValidBitcoinAddress() {
        return address as String
    } else {
        return nil
    }
}

fileprivate func reduceBrightness(ciImage: CIImage) -> UIImage? {
    let context = CIContext()
    guard let brightnessfilter = CIFilter(name: "CIColorControls") else {return nil}
    
    brightnessfilter.setValue(ciImage, forKey: "inputImage")
    brightnessfilter.setValue(0.3 as Float, forKey: "inputBrightness")
    
    guard let outputImage = brightnessfilter.outputImage else {return nil}
    guard let imageRef = context.createCGImage(outputImage, from: outputImage.extent) else {
        return nil
    }
    
    let newUIImage = UIImage(cgImage: imageRef)
    return newUIImage
}
