//
//  PermissionAlert.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 12.01.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct PermissionAlert {
    
    typealias LocalizedStrings = Strings.Scan
    
    func requestPermission(with message: String, cancelHandler: ((UIAlertAction) -> Void)? ) -> UIAlertController {
        let alertController = UIAlertController (title: LocalizedStrings.permissionRequired, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: LocalizedStrings.openSetting, style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        }
        
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: LocalizedStrings.cancel, style: .default, handler: cancelHandler)
        alertController.addAction(cancelAction)
        alertController.preferredAction = settingsAction
        return alertController
    }
}
