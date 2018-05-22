//
//  AuthorizationProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AuthorizationProvider {
    
    private weak var accountProvider: AccountManager!
    private weak var api: API!
    private weak var defaults: Defaults!
    private weak var icloudProvider: ICloud!
    
    init(accountProvider: AccountManager, api: API, defaults: Defaults, icloudProvider: ICloud) {
        self.accountProvider = accountProvider
        self.api = api
        self.defaults = defaults
        self.icloudProvider = icloudProvider
    }
    
    func register(walletDigest: String, completion: ((Result<String>) -> Void)? = nil) {

        let udid = accountProvider.createNewUdid()
        let secret = accountProvider.generateNewSecret()
        let ecdh_pub = accountProvider.generatePubKDH(from: secret)
        
        api.registerSelfUser(with: .new(udid: udid!, walletDigest: walletDigest, ecdhPub: ecdh_pub), completion: { [unowned self] result in
            switch result {
            case .success(let ecdh_serv):
                self.accountProvider.sharedKey(withSecret: secret, andServerPub: ecdh_serv)
                self.authenticateUser(completion: completion)
                Logger.info("Registration success")
                
            case .failure(let error):
                self.restoreRegistration(walletDigest: walletDigest, secret: secret, ecdh_pub: ecdh_pub, completion: completion)
                Logger.warn("Registration failure with \(error.localizedDescription)")
            }
        })
    }
    
    fileprivate func restoreRegistration(walletDigest: String, secret: Data, ecdh_pub: String, completion: ((Result<String>) -> Void)? = nil) {
        
        guard let udid = accountProvider.currentUdid else {
            return
        }
        
        api.registerSelfUser(with: .newDevice(udid: udid, walletDigest: walletDigest, ecdhPub: ecdh_pub), completion: { [unowned self] result in
            
            switch result {
            case .success(let ecdh_serv):
                self.accountProvider.sharedKey(withSecret: secret, andServerPub: ecdh_serv)
                self.authenticateUser(completion: completion)
                
            case .failure:
                self.api.registerSelfUser(with: .restore(udid: udid, walletDigest: walletDigest, ecdhPub: ecdh_pub), completion: { [unowned self] result in
                    switch result {
                    case .success(let ecdh_serv):
                        self.accountProvider.sharedKey(withSecret: secret, andServerPub: ecdh_serv)
                        self.authenticateUser(completion: completion)
                        Logger.info("Successful registration restore")
                        
                    case .failure(let error):
                        Logger.error(error.localizedDescription)
                        completion?(.failure(error))
                    }
                })
            }
        })
    }

}

// MARK: - Private methods

extension AuthorizationProvider {
    
    func authenticate(completion: @escaping (Result<String>) -> Void) {
        api.authentificateNewUser() { result in
            switch result {
            case .success:
                completion(.success("Successfully authenticated"))
            case .failure (let error):
                completion(.failure(error))
            }
        }
    }
    
    fileprivate func authenticateUser(completion: ((Result<String>) -> Void)? = nil) {
        api.authentificateNewUser() { [unowned self] result in
            switch result {
            case .success:
                self.didAuthenticate(completion: completion)
            case .failure (let error):
                Logger.error(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
    fileprivate func didAuthenticate(completion: ((Result<String>) -> Void)? = nil) {
        api.getSelfProfile() { [unowned self] result in
            switch result {
            case .success(let userData):
                try? self.icloudProvider.backup(object: userData)
                Logger.info("Profile restored")
                completion?(.success("Success"))
            case .failure(let error):
                Logger.warn(error.localizedDescription)
                self.createUser(completion: completion)
            }
        }
    }
    
    fileprivate func createUser(completion: ((Result<String>) -> Void)? = nil) {
        let pc = accountProvider.getSelfPCString()
        if let _ = icloudProvider.restoreObjectsFromBackup(LocalUserData.self).first {
            // Already have user profile
            completion?(.success("Success"))
            return
        }
        api.addSelfProfile(pc: pc, name: nil) { result in
            switch result {
            case .success:
                let userData = LocalUserData(name: defaultDisplayName + String(pc.suffix(4)), imageData: nil)
                try? self.icloudProvider.backup(object: userData)
                Logger.info("Profile initialized")
                completion?(.success("Success"))
            case .failure(let error):
                Logger.error(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
}
