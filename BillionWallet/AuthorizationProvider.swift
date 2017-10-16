//
//  AuthorizationProvider.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 18/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

class AuthorizationProvider {
    
    weak var accountProvider: AccountManager?
    weak var api: API?
    weak var defaults: Defaults?
    
    init(accountProvider: AccountManager, api: API, defaults: Defaults) {
        self.accountProvider = accountProvider
        self.api = api
        self.defaults = defaults
    }
    
    func registerNewAccount(walletDigest: String, completion: ((Result<String>) -> Void)? = nil) {
        if accountProvider?.currentUdid == nil {
            accountProvider?.createNewUdid()
        }
        
        let udid = accountProvider?.currentUdid!
        let ecdh_pub = accountProvider?.generatePubKDH(from: (accountProvider?.currentSecret)!)
        
        api?.registerSelfUser(with: .new(udid: udid!, walletDigest: walletDigest, ecdhPub: ecdh_pub!), completion: { [weak self] result in
            switch result {
            case .success(let ecdh_serv):
                self?.accountProvider?.sharedKey(withSecret: (self?.accountProvider?.currentSecret)!, andServerPub: ecdh_serv)
                self?.authenticateUser(completion: completion)
                
            case .failure(let error):
                Logger.error(error.localizedDescription)
                completion?(.failure(error))
            }
        })
    }
    
    func restoreRegistration(walletDigest: String, completion: ((Result<String>) -> Void)? = nil) {
        if accountProvider?.currentUdid == nil {
            accountProvider?.createNewUdid()
        }
        
        let udid = accountProvider?.currentUdid!
        let ecdh_pub = accountProvider?.generatePubKDH(from: (accountProvider?.currentSecret)!)
        
        api?.registerSelfUser(with: .newDevice(udid: udid!, walletDigest: walletDigest, ecdhPub: ecdh_pub!), completion: { [weak self] result in
            
            switch result {
            case .success(let ecdh_serv):
                self?.accountProvider?.sharedKey(withSecret: (self?.accountProvider?.currentSecret)!, andServerPub: ecdh_serv)
                self?.authenticateUser(completion: completion)
                
            case .failure:
                self?.api?.registerSelfUser(with: .restore(udid: udid!, walletDigest: walletDigest, ecdhPub: ecdh_pub!), completion: { [weak self] result in
                    switch result {
                    case .success(let ecdh_serv):
                        self?.accountProvider?.sharedKey(withSecret: (self?.accountProvider?.currentSecret)!, andServerPub: ecdh_serv)
                        
                        self?.authenticateUser(completion: completion)
                        
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
    
    fileprivate func authenticateUser(completion: ((Result<String>) -> Void)? = nil) {
        api?.authentificateNewUser() { [weak self] result in
            switch result {
            case .success:
                self?.didAuthenticate(completion: completion)
            case .failure (let error):
                Logger.error(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
    fileprivate func didAuthenticate(completion: ((Result<String>) -> Void)? = nil) {
        api?.getSelfProfile() { [weak self] result in
            switch result {
            case .success(let userData):
                try? ICloud().backup(object: userData)
                completion?(.success("Success"))
            case .failure(let error):
                Logger.error(error.localizedDescription)
                self?.createUser(completion: completion)
            }
        }
    }
    
    fileprivate func createUser(completion: ((Result<String>) -> Void)? = nil) {
        let pc = BRWalletManager.getKeychainPaymentCode(forAccount: 0)
        api?.addSelfProfile(pc: pc, nick: nil, name: nil) { result in
            
            switch result {
            case .success:
                Logger.info("Profile initialized")
                completion?(.success("Success"))
                
            case .failure(let error):
                Logger.error(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
}
