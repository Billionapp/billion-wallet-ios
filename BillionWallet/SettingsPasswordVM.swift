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
    func didPasswordChanged()
}

class SettingsPasswordVM {
    
    typealias LocalizedStrings = Strings.Settings.Password
    
    weak var application: Application?
    weak var delegate: SettingsPasswordVMDelegate? {
        didSet {
            delegate?.didEnableTouchId(isTouchIdEnabled)
        }
    }
    
    var title: String {
        if Layout.model == .ten {
            return LocalizedStrings.titleTen
        } else {
            return LocalizedStrings.title
        }
    }
    
    var subtitle: String {
        if Layout.model == .ten {
            return LocalizedStrings.subtitleTen
        } else {
            return LocalizedStrings.subtitle
        }
    }
    
    var securityButtonTitle: String {
        if Layout.model == .ten {
            return LocalizedStrings.faceIDEnable
        } else {
            return LocalizedStrings.touchIdSwitch
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
    
    func didUpdatePasscode(_ passcode: String) {
        application?.keychain.pin = passcode
        delegate?.didPasswordChanged()
    }
    
}
