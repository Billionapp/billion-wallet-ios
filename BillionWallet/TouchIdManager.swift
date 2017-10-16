//
//  TouchIDManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 02.08.17.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import LocalAuthentication

final class TouchIDManager {

    let authContext = LAContext()
    
    var isTouchIdOn: Bool {
        get {
            let defaults = Defaults()
            return defaults.isTouchIdEnabled
        }
        set {
            let defaults = Defaults()
            defaults.isTouchIdEnabled = newValue
        }
    }
    
    func authentificateUser(with password: String, success: () -> Void, failure: (String) -> Void) {
        if BRWalletManager.getKeyChainPassword() != nil {
            failure("Password is set")
        } else {
            BRWalletManager.setKeyChainPassword(password)
            success()
        }
    }
    
    func unlock(password: String?, success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        if isTouchIdOn {
            self.unlockWithTouchId(success: success, failure: failure)
        } else {
            guard let pas = password  else {
                failure("Unknown error")
                return
            }
            
            self.unlockWithPassword(password: pas, success: success, failure: failure)
        }
    }
    
    func changePassword(with password: String?) {
        BRWalletManager.setKeyChainPassword(password)
    }
    
    func touchIdAvailability(success: @escaping () -> Void, failure: @escaping (NSError) -> Void) {
        var authError: NSError?
        let touchIdSetOnDevice = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError)
        if touchIdSetOnDevice {
            isTouchIdOn = true
            DispatchQueue.main.async {
                success()
            }
        } else {
            isTouchIdOn = false
            DispatchQueue.main.async {
                failure(authError!)
            }
        }
    }
    
    private func unlockWithTouchId(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        touchIdAvailability(success: {
            self.authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Use your bio to authenticate.", reply: { (ok, error) in
                if ok {
                    DispatchQueue.main.async {
                        success()
                    }
                    return
                }
            })
        }) { (error) in
            let error = self.errorMessageForLAErrorCode(error: error)
            failure(error)
        }
    }
    
    private func unlockWithPassword(password: String, success: () -> Void, failure: (String) -> Void) {
        if password == BRWalletManager.getKeyChainPassword() {
            success()
        } else {
            failure("Wrong password.")
        }
    }

}

extension TouchIDManager {
    func errorMessageForLAErrorCode( error: NSError ) -> String{
        var message = ""
        
        switch error {
            
        case LAError.appCancel:
            message = "Authentication was cancelled by application"
            
        case LAError.authenticationFailed:
            message = "The user failed to provide valid credentials"
            
        case LAError.invalidContext:
            message = "The context is invalid"
            
        case LAError.passcodeNotSet:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel:
            message = "Authentication was cancelled by the system"
            
        case LAError.touchIDLockout:
            message = "Too many failed attempts."
            
        case LAError.touchIDNotAvailable:
            message = "TouchID is not available on the device"
            
        case LAError.userCancel:
            message = "The user did cancel"
            
        case LAError.userFallback:
            message = "The user chose to use the fallback"
            
        case LAError.touchIDNotEnrolled:
            message = "Authentication could not start, because Touch ID has no enrolled fingers."
            
        default:
            message = "Did not find error code on LAError object"
            
        }
        
        return message
    }
}
