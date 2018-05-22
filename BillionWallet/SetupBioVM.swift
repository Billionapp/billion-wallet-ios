//
//  SetupBioVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol SetupBioVMDelegate: class {
    func didFinishSetup()
}

class SetupBioVM {
    
    private let iCloudProvider: ICloud
    private let keychain: Keychain
    private let defaultsProvider: Defaults
    weak var delegate: SetupBioVMDelegate?
    typealias LocalizedString = Strings.SetupBio
    
    init(defaultsProvider: Defaults, keychain: Keychain, iCloudProvider: ICloud) {
        self.defaultsProvider = defaultsProvider
        self.keychain = keychain
        self.iCloudProvider = iCloudProvider
    }
    
    var title: String {
        if Layout.model == .ten {
            return LocalizedString.titleTen
        } else {
            return LocalizedString.title
        }
    }
    
    var switchTitle: String {
        if Layout.model == .ten {
            return LocalizedString.faceIdSwitchTitle
        } else {
            return LocalizedString.touchIdSwitchTitle
        }
    }
    
    var isTouchIdEnabled: Bool {
        return defaultsProvider.isTouchIdEnabled
    }
    
    func setup(isOn: Bool) {
        defaultsProvider.isTouchIdEnabled = isOn
    }
    
    func iCloudPicture() -> Data? {
        return iCloudProvider.restoreObjectsFromBackup(LocalUserData.self).first?.imageData
    }
    
    func iCloudName() -> String? {
        return iCloudProvider.restoreObjectsFromBackup(LocalUserData.self).first?.name
    }
}

extension SetupBioVM: PasscodeOutputDelegate {
    func didCompleteVerification() {
        //
    }
    
    func didUpdatePasscode(_ passcode: String) {
        keychain.pin = passcode
        didCompleteVerification()
    }
}
