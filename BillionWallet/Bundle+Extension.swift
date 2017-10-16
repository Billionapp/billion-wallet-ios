//
//  Bundle+Extension.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension Bundle {
    
    class var appVersion: String {
       return main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    }

}
