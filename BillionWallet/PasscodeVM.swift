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
    func didUpdate(symbolCount: Int)
    func didUpdateMaxDots(_ maxDots: Int)
    func didClearInput()
    func didCancelVerification()
}

protocol PasscodeVM: class {
    var pinSize: Int { get }
    
    var delegate: PasscodeVMDelegate? { get set }
    var output: PasscodeOutputDelegate? { get set }
    
    var passcodeCase: PasscodeCase { get set }
    
    func pinInput(_ symbol: String)
    func backspace()
    func cancel()
}

class UniversalPinVM: PasscodeVM {
    weak var delegate: PasscodeVMDelegate?
    weak var output: PasscodeOutputDelegate?
    
    private let lockProvider: LockProvider
    private let touchIdProvider: TouchIdProvider
    var pinSize: Int
    
    var reason: String?
    
    var passcodeCase: PasscodeCase = .createFirst {
        didSet {
            delegate?.didUpdatePasscodeCase(passcodeCase)
        }
    }
    
    private var pin: String = "" {
        didSet {
            updateSymbolCount()
            check()
        }
    }
    
    private var touchIdEnabled: Bool {
        return touchIdProvider.isTouchIdEnabled
    }
    
    init(touchIdProvider: TouchIdProvider,
         passcodeCase: PasscodeCase,
         output: PasscodeOutputDelegate?,
         lockProvider: LockProvider,
         reason: String?,
         pinSize: Int) {
        
        self.touchIdProvider = touchIdProvider
        self.passcodeCase = passcodeCase
        self.output = output
        self.lockProvider = lockProvider
        self.reason = reason
        self.pinSize = pinSize
    }
    
    /// Using by router before presentong view. Fallback block must present view if needed
    func showTouchIdIfNeeded(withFallback fallback: @escaping () -> Void) {
        guard passcodeCase.showTouchId else {
            fallback()
            return
        }
        touchIdProvider.authenticateWithBiometrics(reason: reason) { [weak self] success in
            if success {
                self?.didUnlock()
            } else {
                fallback()
            }
        }
    }
    
    func backspace() {
        if pin.count > 0 {
            pin.removeLast()
            updateSymbolCount()
        }
    }
    
    func pinInput(_ symbol: String) {
        if pin.count < pinSize {
            pin += symbol
        }
    }
    
    func cancel() {
        switch passcodeCase {
        case .createSecond:
            passcodeCase = .createFirst
        default:
            delegate?.didCancelVerification()
            output?.didCancelVerification()
        }
    }
    
    private func check() {
        guard pin.count == pinSize else {
            return
        }
        
        // Timeout for user to let him see last symbol input
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [unowned self] in
            self.handlePasscodeCase()
        }
    }
    
    private func handlePasscodeCase() {
        if passcodeCase.verify(code: pin) {
            switch passcodeCase {
            case .createFirst:
                passcodeCase = .createSecond(lastPasscode: pin)
                
            case .createSecond:
                delegate?.didFinishVerification()
                output?.didUpdatePasscode(pin)
                
            case .updateOld:
                passcodeCase = .updateNewFirst
            
            case .migrate(let pinSize):
                passcodeCase = .migrateUpdateFirst
                self.pinSize = pinSize
                delegate?.didUpdateMaxDots(pinSize)
                
            case .updateNewFirst:
                passcodeCase = .updateNewSecond(lastPasscode: pin)
                
            case .migrateUpdateFirst:
                passcodeCase = .migrateUpdateSecond(newPasscode: pin)
                
            case .updateNewSecond, .migrateUpdateSecond:
                output?.didUpdatePasscode(pin)
                delegate?.didFinishVerification()
                
            case .lock, .custom:
                didUnlock()
            }
            
            clearPin()
        } else {
            clearPin()
            delegate?.didEnterWrongCode()
        }
    }
    
    private func updateSymbolCount() {
        if pin.count > 0 {
            delegate?.didUpdate(symbolCount: pin.count)
        } else {
            delegate?.didClearInput()
        }
    }
    
    private func clearPin() {
        pin = ""
    }
    
    private func didUnlock() {
        lockProvider.unlock()
        output?.didCompleteVerification()
        delegate?.didFinishVerification()
    }
    
}
