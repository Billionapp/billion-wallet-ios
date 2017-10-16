//
//  AddressContact+ICloud.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

extension AddressContact: ICloudBackupProtocol {

    static var folder: String? {
        return ICloud.BackupDestination.contacts + "/address"
    }
    
    var destination: String {
        return address + "/\(address)"
    }
    
    var backupJson: [String: Any] {
        return [
            "displayName": displayName,
            "isAvatarSet": isAvatarSet,
            "isArchived": isArchived,
            "address": address,
            "txHashes": Array(txHashes)
            ].removeNils()
    }
    
    init(from json: [String: Any], with attachData: Data?) throws {
        
        guard let displayName = json["displayName"] as? String, let address = json["address"] as? String else {
            throw ICloud.ICloudError.restoringFromJsonError
        }
        
        let isArchived = json["isArchived"] as? Bool ?? false
        let txHashes = json["txHashes"] as? [String] ?? []
        
        self.init(address: address, displayName: displayName, avatarData: attachData, isArchived: isArchived, txHashes: Set(txHashes))
    }
    
}
