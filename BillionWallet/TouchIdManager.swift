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

    typealias LocalizedStrings = Strings.Authentication
    
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
    
    @available(iOS 11.0, *)
    func biometryType() -> LABiometryType {
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            return authContext.biometryType
        }
        return authContext.biometryType
    }
    
    func faceIdIsAvaliable() -> Bool {
        if #available(iOS 11.0, *) {
            return biometryType() == LABiometryType.faceID
        }
        return false
    }
    
    private func unlockWithTouchId(success: @escaping () -> Void, failure: @escaping (String) -> Void) {
        var localizedReason = LocalizedStrings.touchIDAuthReason
        if faceIdIsAvaliable() {
            localizedReason = LocalizedStrings.faceIDAuthReason
        }
        touchIdAvailability(success: {
            self.authContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason, reply: { (ok, error) in
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
}

extension TouchIDManager {
    func errorMessageForLAErrorCode( error: NSError ) -> String {
        // FIXME: Localize reasons
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
