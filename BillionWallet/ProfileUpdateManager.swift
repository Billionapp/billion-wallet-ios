//
//  ProfileUpdateManager.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04.03.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class ProfileUpdateManager {
    private let api: API
    private let icloud: ICloud
    
    private var successProfile: Bool = false
    private var successAvatar: Bool = false
    private var done: Bool = true
    private let lock: NSLock
    
    init(api: API, icloud: ICloud) {
        self.api = api
        self.icloud = icloud
        self.lock = NSLock()
        self.done = true
    }
    
    func updateUserProfile(completion: @escaping (Result<String>) -> Void) {
        if !done {
            completion(.failure(ProfileUpdateManagerError.requestIsAlreadyActive))
            return
        }
        reset()
        if let userData = icloud.restoreObjectsFromBackup(LocalUserData.self).first {
            if let name = userData.name {
                api.updateSelfProfile(name: name) { result in
                    switch result {
                    case .success:
                        self.profileDidUpdate(completion)
                    case .failure(let error):
                        self.updateDidFail(completion, error: error)
                    }
                }
            }
            if let image = userData.imageData {
                api.addSelfAvatar(imageData: image) { result in
                    switch result {
                    case .success:
                        self.avatarDidUpdate(completion)
                    case .failure(let error):
                        self.updateDidFail(completion, error: error)
                    }
                }
            }
        } else {
            completion(.failure(ProfileUpdateManagerError.userDataUnavailable))
        }
    }
    
    private func reset() {
        lock.lock()
        successProfile = false
        successAvatar = false
        done = false
        lock.unlock()
    }
    
    private func profileDidUpdate(_ completion: @escaping (Result<String>) -> Void) {
        lock.lock()
        defer {
            lock.unlock()
        }
        successProfile = true
        if successAvatar && !done {
            done = true
            completion(.success(""))
        }
    }
    
    private func avatarDidUpdate(_ completion: @escaping (Result<String>) -> Void) {
        lock.lock()
        defer {
            lock.unlock()
        }
        successAvatar = true
        if successProfile && !done {
            done = true
            completion(.success(""))
        }
    }
    
    private func updateDidFail(_ completion: @escaping (Result<String>) -> Void, error: Error) {
        lock.lock()
        defer {
            lock.unlock()
        }
        if !done {
            done = true
            completion(.failure(error))
        }
    }
}

// FIXME: Localize
enum ProfileUpdateManagerError: LocalizedError {
    case userDataUnavailable
    case requestIsAlreadyActive
    
    var errorDescription: String? {
        switch self {
        case .userDataUnavailable:
            return "User data unavailable"
        case .requestIsAlreadyActive:
            return "A request to update profile is already active"
        }
    }
}
