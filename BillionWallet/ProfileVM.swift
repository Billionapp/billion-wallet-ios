//
//  ProfileVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 14/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation
import UIKit

protocol  ProfileVMDelegate: class {
    func update(userData: LocalUserData?)
    func closeView()
}

class ProfileVM {
    
    weak var delegate: ProfileVMDelegate?
    weak var api: API?
    weak var icloudProvider: ICloud?
    weak var defaults: Defaults?

    var userData: LocalUserData?
    
    var photo: Data?
    var name: String?
    var nick: String?
    
    init(api: API, icloudProvider: ICloud, defaults: Defaults) {
        self.api = api
        self.icloudProvider = icloudProvider
        self.defaults = defaults
        
        if let userData = icloudProvider.restoreObjectsFromBackup(LocalUserData.self).first {
            self.userData = userData
            delegate?.update(userData: userData)
        }
    }
    
    func save() {
        if nick != nil || name != nil {
            updateUserData()
        } else if photo != nil {
            updateAvatar()
        }
    }
    
    func cancel() {
        clearChanges()
        delegate?.update(userData: userData)
    }
    
    func getPaymentCodeQRImage() -> UIImage? {
        let pc = BRWalletManager.getKeychainPaymentCode(forAccount: 0)
        return createQRFromString(pc, size: CGSize(width: 150, height: 150), inverseColor: true)
    }
    
    fileprivate func updateUserData() {
        
        api?.updateSelfProfile(nick: nick, name: name) { [weak self] result in
            guard let this = self else { return }
            
            switch result {
            case .success:
                
                if this.photo != nil {
                    this.updateAvatar()
                    
                } else {
                    this.backupUserData()
                }
                
                self?.delegate?.closeView()
                
            case .failure:
                this.delegate?.update(userData: this.userData)
            }
        }
        
    }
    
    fileprivate func updateAvatar() {
        guard let photo = photo else {
            return
        }
        
        api?.addSelfAvatar(imageData: photo) { [weak self] result in
            guard let this = self else { return }
            
            switch result {
            case .success:
                this.backupUserData()
            case .failure:
                this.delegate?.update(userData: this.userData)
            }
        }
    }
    
    fileprivate func backupUserData() {
        userData = LocalUserData(name: name ?? userData?.name, nick: nick ?? userData?.nick, imageData: photo ?? userData?.imageData)
        try? icloudProvider?.backup(object: userData!)
        clearChanges()
    }
    
    fileprivate func clearChanges() {
        name = nil
        nick = nil
        photo = nil
    }
    
}
