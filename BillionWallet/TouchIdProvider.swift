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

    func authenticateWithBiometrics(reason: String?, completion: @escaping (Bool) -> Void) {
        
        guard isTouchIdEnabled else {
            completion(false)
            return
        }
        
        let context = LAContext()
        var reason = reason ?? Strings.TouchId.authRequired
        if reason == "" { reason = Strings.TouchId.authRequired }
        
        context.localizedFallbackTitle = Strings.TouchId.enterPasscode
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }

    }
    
}
