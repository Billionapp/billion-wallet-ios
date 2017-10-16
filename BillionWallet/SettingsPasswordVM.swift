//
//  SettingsPasswordVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 10/08/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol SettingsPasswordVMDelegate: class {
    func didEnableTouchId(_ isOn: Bool)
}

class SettingsPasswordVM {
    
    weak var application: Application?
    weak var delegate: SettingsPasswordVMDelegate? {
        didSet {
            delegate?.didEnableTouchId(isTouchIdEnabled)
        }
    }
    
    var defaultsProvider: Defaults? {
        return application?.defaults
    }
    
    var passcode: String? {
        return application?.keychain.pin
    }
    
    var isTouchIdEnabled: Bool! {
        didSet {
            delegate?.didEnableTouchId(isTouchIdEnabled)
            defaultsProvider?.isTouchIdEnabled = isTouchIdEnabled
        }
    }
    
    init(application: Application) {
        self.application = application
        self.isTouchIdEnabled = defaultsProvider?.isTouchIdEnabled
    }
    
}

// MARK: - PasscodeOutputDelegate

extension SettingsPasswordVM: PasscodeOutputDelegate {
    
    func didCompleteVerification() {
        
    }
    
    func didUpdatePascode(_ passcode: String) {
        application?.keychain.pin = passcode
    }
    
}
