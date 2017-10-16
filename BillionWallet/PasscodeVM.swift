//
//  PasscodeVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol PasscodeVMDelegate: class {
    func didUpdatePasscodeCase(_ passcodeCase: PasscodeCase)
    func didEnterWrongCode()
    func didFinishVerification()
    func didUpdatePin()
}

class PasscodeVM {
    
    weak var delegate: PasscodeVMDelegate?
    weak var output: PasscodeOutputDelegate?
    weak var lockListener: LockDelegate?
    
    var passcodeCase: PasscodeCase = .createFirst {
        didSet {
            delegate?.didUpdatePasscodeCase(passcodeCase)
        }
    }
    
    var pin: String = "" {
        didSet {
            delegate?.didUpdatePin()
            check()
        }
    }
    
    var touchIdEnabled: Bool {
        return  touchIdProvider?.isTouchIdEnabled ?? false
    }
    
    weak var touchIdProvider: TouchIdProvider?
    
    init(touchIdProvider: TouchIdProvider, passcodeCase: PasscodeCase, output: PasscodeOutputDelegate?) {
        self.touchIdProvider = touchIdProvider
        self.passcodeCase = passcodeCase
        self.output = output
    }
    
    func lockDeviceIfNeeded() {
        switch passcodeCase {
        case .lock:
            var keychain = Keychain()
            keychain.isLocked = true
        default:
            break
        }
    }
    
    fileprivate func check() {
        guard pin.characters.count == 4 else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
            self.handlePasscodeCase()
        }
    }
    
    fileprivate func handlePasscodeCase() {
        if passcodeCase.verify(code: pin) {
            switch passcodeCase {
            case .createFirst:
                passcodeCase = .createSecond(lastPasscode: pin)
                
            case .createSecond:
                delegate?.didFinishVerification()
                output?.didUpdatePascode(pin)
                
            case .updateOld:
                passcodeCase = .updateNewFirst
                
            case .updateNewFirst:
                passcodeCase = .updateNewSecond(lastPasscode: pin)
                
            case .updateNewSecond:
                output?.didUpdatePascode(pin)
                delegate?.didFinishVerification()
                
            case .lock, .custom:
                var keychain = Keychain()
                keychain.isLocked = false
                output?.didCompleteVerification()
                delegate?.didFinishVerification()
                lockListener?.didUnlock()
            }
            
            clearPin()
        } else {
            clearPin()
            delegate?.didEnterWrongCode()
        }
    }
    
    func clearPin() {
        pin = ""
    }
    
    func verifyWithTouchIdIfNeeded() {
        if passcodeCase.showTouchId {
            verifyWithTouchId()
        }
    }
    
    func verifyWithTouchId() {
        touchIdProvider?.authenticateWithBiometrics { [weak self] in
            self?.output?.didCompleteVerification()
            self?.delegate?.didFinishVerification()
            self?.lockListener?.didUnlock()
        }
    }
    
}
