//
//  SetupCardVM.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 26/02/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

protocol SetupCardVMDelegate: class {
    func didPickImage(frame: CGRect)
    func didFinishSetup()
}

class SetupCardVM: NSObject {

    weak var delegate: SetupCardVMDelegate?
    
    var selectedImage: UIImage?
    private var avatars: [UIImage]
    
    let paymentCodeString: String
    private let accountProvider: AccountManager
    private let api: API
    private let icloudProvider: ICloud
    private let taskQueueProvider: TaskQueueProvider
    private let defaults: Defaults
    
    private let updateQueue: DispatchQueue
    
    private var nameIsUpdated: Bool
    private var avatarIsUpdated: Bool
    var avatar: UIImage? {
        didSet {
            avatarIsUpdated = true
        }
    }
    var name: String? {
        didSet {
            nameIsUpdated = true
        }
    }
    
    init(api: API,
         icloudProvider: ICloud,
         accountProvider: AccountManager,
         taskQueueProvider: TaskQueueProvider,
         defaults: Defaults,
         avatarData: Data?,
         nameOld: String?) {
        
        self.api = api
        self.icloudProvider = icloudProvider
        self.accountProvider = accountProvider
        self.taskQueueProvider = taskQueueProvider
        self.defaults = defaults
        
        self.updateQueue = DispatchQueue(label: "\(type(of: self))-update")
        self.paymentCodeString = accountProvider.getSelfPCString()
        let names = (0...11).map({ "Avatar"+String($0) })
        self.avatars = names.map({ UIImage.init(named: $0)! })
        self.nameIsUpdated = false
        self.avatarIsUpdated = false
        if avatarData != nil {
            self.avatar = UIImage(data:avatarData!,scale:2.0)
            self.avatarIsUpdated = true
        }
        if let nameUnwraped = nameOld {
            self.name = nameUnwraped
        }
    }
    
    func imageWithLayer(layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setBlendMode(.screen)
        layer.render(in: context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func uploadName(name: String) {
        self.name = name
        nameIsUpdated = true
        saveUserData()
        setupFinished()
        let taskQueueProvider = self.taskQueueProvider
        DispatchQueue.global().async {
            self.api.updateSelfProfile(name: name) { (result) in
                switch result {
                case .success:
                    Logger.debug("User profile name updated successfully.")
                case .failure(let error):
                    Logger.error(error.localizedDescription)
                    taskQueueProvider.addOperation(type: .updateProfile)
                }
            }
        }
    }
    
    func uploadAvatar(avatar: UIImage) {
        self.avatar = avatar
        avatarIsUpdated = true
        saveUserData()
        let taskQueueProvider = self.taskQueueProvider
        DispatchQueue.global().async {
            self.api.addSelfAvatar(imageData: avatar.tuneCompress()) { (result) in
                switch result {
                case .success:
                    Logger.debug("User avatar updated successfully.")
                case .failure(let error):
                    Logger.error(error.localizedDescription)
                    taskQueueProvider.addOperation(type: .updateProfile)
                }
            }
        }
    }
    
    func saveUserData() {
        if avatarIsUpdated {
            updateQueue.async {
                let newUserData = LocalUserData(name: self.name, imageData: self.avatar?.tuneCompress())
                try? self.icloudProvider.backup(object: newUserData)
            }
        }
    }
    
    func setupFinished() {
        if nameIsUpdated {
            defaults.appStarted = true
            delegate?.didFinishSetup()
        }
    }
}

extension SetupCardVM: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupAvatarCell", for: indexPath) as! SetupAvatarCell
        cell.avatar.image = avatars[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImage = avatars[indexPath.row]
        avatars[indexPath.row] = UIImage.init(color: UIColor.clear)!
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SetupAvatarCell", for: indexPath) as! SetupAvatarCell
        delegate?.didPickImage(frame: cell.frame)
    }
}
