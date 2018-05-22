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
    func didReceiveUserData(_ contact: LocalUserData?)
    func closeView()
    func didReceiveSharePicture(card: UIImage)
}

class ProfileVM {
    
    weak var delegate: ProfileVMDelegate?
    private weak var api: API!
    private weak var icloudProvider: ICloud!
    private weak var defaults: Defaults!
    private let accountProvider: AccountManager!
    
    private var userData: LocalUserData?
    private var newName: String?
    private var newPhoto: Data?
    
    var paymentCodeString: String!
    
    init(api: API, icloudProvider: ICloud, defaults: Defaults, accountProvider: AccountManager) {
        self.api = api
        self.icloudProvider = icloudProvider
        self.defaults = defaults
        self.accountProvider = accountProvider
        self.paymentCodeString = accountProvider.getSelfPCString()
    }
    
    func getUserData() {
        if let userData = icloudProvider.restoreObjectsFromBackup(LocalUserData.self).first {
            self.userData = userData
            delegate?.didReceiveUserData(userData)
        }
    }
    
    func setName(to name: String) {
        newName = name
    }
    
    func setPhoto(to photo: Data) {
        newPhoto = photo
    }
    
    func save() {
        if let name = newName {
            updateUserData(name: name)
        }
        
        if let photo = newPhoto {
            updateAvatar(photo: photo)
        }
        
        if newName == nil && newPhoto == nil {
            delegate?.closeView()
        }
    }
    
    func cancel() {
        clearChanges()
        delegate?.didReceiveUserData(userData)
    }
    
    func shareContact(card: UIImage) {
        delegate?.didReceiveSharePicture(card: card)
    }
    
    func getPaymentCodeQRImage() -> UIImage? {
        return createQRFromString(paymentCodeString, size: CGSize(width: 150, height: 150), inverseColor: true)
    }
    
    fileprivate func updateUserData(name: String) {
        api?.updateSelfProfile(name: name) { [weak self] result in
            
            switch result {
            case .success:
                
                if let userData = self?.icloudProvider.restoreObjectsFromBackup(LocalUserData.self).first {
                    let newUserData = LocalUserData(name: name, imageData: userData.attach?.data)
                    try? self?.icloudProvider.backup(object: newUserData)
                }
                
                self?.finish()
            case .failure:
                Logger.warn("Cannot update profile")
                self?.delegate?.didReceiveUserData(self?.userData)
            }
        }
        
    }
    
    fileprivate func updateAvatar(photo: Data) {
        api?.addSelfAvatar(imageData: photo) { [weak self] result in
            
            switch result {
            case .success:
                
                if let userData = self?.icloudProvider.restoreObjectsFromBackup(LocalUserData.self).first {
                    let newUserData = LocalUserData(name: userData.name, imageData: photo)
                    try? self?.icloudProvider.backup(object: newUserData)
                }
                
                self?.finish()
            case .failure:
                self?.delegate?.didReceiveUserData(self?.userData)
            }
        }
    }

    fileprivate func finish() {
        userData = LocalUserData(name: newName ?? userData?.name, imageData: newPhoto ?? userData?.imageData)
        delegate?.didReceiveUserData(userData)
        clearChanges()
    }
    
    fileprivate func clearChanges() {
        newName = nil
        newPhoto = nil
    }
    
}
