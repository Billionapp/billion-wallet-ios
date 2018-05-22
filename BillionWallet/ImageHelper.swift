//
//  ImageHelper.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 24/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension UIImage {
    
    func cropTo(size: CGSize) -> UIImage {
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        var cropWidth: CGFloat = size.width
        var cropHeight: CGFloat = size.height
        
        if (self.size.height < size.height || self.size.width < size.width){
            return self
        }
        
        let heightPercentage = self.size.height/size.height
        let widthPercentage = self.size.width/size.width
        
        if (heightPercentage < widthPercentage) {
            cropHeight = size.height*heightPercentage
            cropWidth = size.width*heightPercentage
        } else {
            cropHeight = size.height*widthPercentage
            cropWidth = size.width*widthPercentage
        }
        
        let posX: CGFloat = (self.size.width - cropWidth)/2
        let posY: CGFloat = (self.size.height - cropHeight)/2
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return cropped
    }
    
    func resizeTo(newSize: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIView {
    func makeSnapshot(immediately: Bool = true) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        drawHierarchy(in: bounds, afterScreenUpdates: !immediately)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

func captureScreen(view: UIView) -> UIImage {
    let image = view.makeSnapshot()
    let tintColor = UIColor.black.withAlphaComponent(0.3)
    return image!.applyBlur(withRadius: 23, tintColor: tintColor, saturationDeltaFactor: 1.0, maskImage: nil)
}

