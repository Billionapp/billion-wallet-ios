//
//  UIImage+Contact.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension ContactProtocol {
    func createAvatarImage() -> UIImage {
        let firstChar = String(displayName.characters.first!)
        var secondChar = ""
        if displayName.characters.count > 1 {
            let index = displayName.index(displayName.startIndex, offsetBy: 1)
            secondChar = String(displayName[index])
        }
        let hash = abs(displayName.hashValue)
        let colorNum = hash % (256*256*256)
        let red = colorNum >> 16
        let green = (colorNum & 0x00FF00) >> 8
        let blue = (colorNum & 0x0000FF)
        let textColor = UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
        
        let hash2 = abs(firstChar.hashValue)
        let colorNum2 = hash2 % (256*256*256)
        let red2 = colorNum2 >> 16
        let green2 = (colorNum & 0x00FF00) >> 8
        let blue2 = (colorNum & 0x0000FF)
        let backColor = UIColor(red: CGFloat(red2)/255.0, green: CGFloat(green2)/255.0, blue: CGFloat(blue2)/255.0, alpha: 0.4)
        
        let label = UILabel()
        label.frame.size = CGSize(width: 124, height: 124)
        label.textColor = textColor
        label.font = UIFont.boldSystemFont(ofSize: label.frame.size.width/1.8)
        label.text = firstChar + secondChar
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = backColor
        label.layer.cornerRadius = 40
        
        label.layer.masksToBounds = true
        UIGraphicsBeginImageContext(label.frame.size)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

