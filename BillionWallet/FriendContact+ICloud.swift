//
//  FriendContact+ICloud.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension FriendContact: ICloudBackupProtocol {
    
    static var folder: String? {
        return ICloud.BackupDestination.contacts + "/friend"
    }
    
    var destination: String {
        return paymentCode + "/\(paymentCode)"
    }
    
    var attach: ICloudAttach? {
        return .image(data: avatarData)
    }
    
    var backupJson: [String: Any] {
        return [
            "displayName": displayName,
            "isAvatarSet": isAvatarSet,
            "isArchived": isArchived,
            "txHashes": Array(txHashes),
            "lastUsed": lastUsed,
            "nickname": nickname,
            "paymentCode": paymentCode,
            "firstUnusedIndex": firstUnusedIndex,
            "receiveAddresses": receiveAddresses,
            "notificationTxHash": notificationTxHash
            ].removeNils()
    }
    
    init(from json: [String: Any], with attachData: Data?) throws {
        
        guard
            let displayName = json["displayName"] as? String,
            let pc = json["paymentCode"] as? String,
            let receiveAddresses = json["receiveAddresses"] as? [String],
            let sendAddresses = json["sendAddresses"] as? [String] else {
            throw ICloud.ICloudError.restoringFromJsonError
        }
        
        let nickname = json["nickname"] as? String
        let isArchived = json["isArchived"] as? Bool ?? false
        let txHashes = json["txHashes"] as? [String] ?? []
        let lastUsed = json["lastUsed"] as? NSNumber ?? NSNumber(value: Double(0))
        let firstUnusedIndex = json["firstUnusedIndex"] as? Int ?? 0
        let notificationTxHash = json["notificationTxHash"] as? String
        let incomingNotificationTxHash = json["incomingNotificationTxHash"] as? String
        let notificationAddress = json["notificationAddress"] as? String
        
        self.init(nickname: nickname,
                 displayName: displayName,
                 avatarData: attachData,
                 isArchived: isArchived,
                 txHashes: Set(txHashes),
                 lastUsed: lastUsed,
                 paymentCode: pc,
                 firstUnusedIndex: firstUnusedIndex,
                 receiveAddresses: receiveAddresses,
                 sendAddresses: sendAddresses,
                 notificationTxHash: notificationTxHash,
                 incomingNotificationTxhash: incomingNotificationTxHash,
                 notificationAddress: notificationAddress)
    }
    
}
