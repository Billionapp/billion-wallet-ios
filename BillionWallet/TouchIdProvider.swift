//
//  TouchIdProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 05/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import LocalAuthentication


class TouchIdProvider: NSObject {
    
    weak var defaults: Defaults?
    
    var isTouchIdEnabled: Bool {
        return defaults?.isTouchIdEnabled ?? false
    }
    
    init(defaults: Defaults) {
        self.defaults = defaults
    }

    func authenticateWithBiometrics(completion: @escaping () -> Void) {
        
        guard isTouchIdEnabled else {
            return
        }
        
        let context = LAContext()
        let reason = NSLocalizedString("Authentication required to proceed", comment: "")
        
        context.localizedFallbackTitle = NSLocalizedString("Enter Passcode", comment: "")
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion()
                }
            }
        }

    }
    
}
