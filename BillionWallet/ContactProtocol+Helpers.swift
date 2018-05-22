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
        return displayName.createAvatarImage()
    }
}

