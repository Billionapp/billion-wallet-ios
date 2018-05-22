//
//  String+AvatarImage.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension String {
    
    func createAvatarImage() -> UIImage {
        let firstChar = String(first ?? "0")
        var secondChar = ""
        if count > 1 {
            let index = self.index(startIndex, offsetBy: 1)
            secondChar = String(self[index])
        }
        let hash = abs(hashValue)
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
        let backColor = UIColor(red: CGFloat(red2)/255.0, green: CGFloat(green2)/255.0, blue: CGFloat(blue2)/255.0, alpha: 1).darker()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 124, height: 124))
        label.textColor = textColor
        label.font = UIFont.boldSystemFont(ofSize: label.frame.size.width/1.8)
        label.text = firstChar + secondChar
        label.textAlignment = NSTextAlignment.center
        label.backgroundColor = backColor
        
        label.layer.masksToBounds = true
        UIGraphicsBeginImageContext(label.frame.size)
        label.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        label.layer.contents = nil
        return image!
    }
}
