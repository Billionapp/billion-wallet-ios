//
//  PaymentRequestMigratorv051.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 20/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

class PaymentRequestMigratorv051: VersionMigrator {
    
    let oldVersion: Version = "0.0.0"
    let newVersion: Version = "0.5.1"
    
    let selfPRstorage: SelfPaymentRequestStorageProtocol
    let userPRstorage: UserPaymentRequestStorageProtocol
    
    init(selfPRstorage: SelfPaymentRequestStorageProtocol, userPRstorage: UserPaymentRequestStorageProtocol) {
        self.selfPRstorage = selfPRstorage
        self.userPRstorage = userPRstorage
    }
    
    func migrateData() {
        migrateUsetPR()
        migrateSelfPR()
    }
    
    private func migrateUsetPR() {
        userPRstorage.getListUserPaymentRequest({ (urls) in
            urls.forEach { url in
                self.userPRstorage.getUserPaymentRequest(url: url, completion: { jsonString in
                    var json = JSON(parseJSON: jsonString)
                    json["fixFiatAmount"] = false
                    let id = json["identifier"].stringValue
                    self.selfPRstorage.saveSelfPaymentRequest(identifier: id, jsonString: json.description, completion: {
                        Logger.info("\(id) payment request migrated")
                    }, failure: { error in
                        Logger.error(error.localizedDescription)
                    })
                }) { error in
                    Logger.error(error.localizedDescription)
                }
            }
        }) { error in
            Logger.error(error.localizedDescription)
        }
    }
    
    private func migrateSelfPR() {
        selfPRstorage.getListSelfPaymentRequest({ (urls) in
            urls.forEach { url in
                self.selfPRstorage.getSelfPaymentRequest(url: url, completion: { jsonString in
                    var json = JSON(parseJSON: jsonString)
                    json["fixFiatAmount"] = false
                    let id = json["identifier"].stringValue
                    self.selfPRstorage.saveSelfPaymentRequest(identifier: id, jsonString: json.description, completion: {
                       Logger.info("\(id) payment request migrated")
                    }, failure: { error in
                        Logger.error(error.localizedDescription)
                    })
                }) { error in
                    Logger.error(error.localizedDescription)
                }
            }
        }) { error in
            Logger.error(error.localizedDescription)
        }
    }
}
