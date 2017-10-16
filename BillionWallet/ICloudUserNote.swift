//
//  ICloudUserNote.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 07/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct ICloudUserNote {
    
    struct UserNoteKeys {
        static let userNote = "userNote"
        static let txHash = "txHash"
    }
    
    let userNote: String
    let txHash: String

}

// MARK: - ICloudBackupProtocol

extension ICloudUserNote: ICloudBackupProtocol {
    
    static var folder: String? {
        return ICloud.BackupDestination.comments
    }
    
    var destination: String {
        return txHash + "/\(txHash)"
    }
    
    var backupJson: [String: Any] {
        return [UserNoteKeys.userNote: userNote, UserNoteKeys.txHash: txHash]
    }
    
    init(from json: [String: Any], with attachData: Data?) throws {
        
        guard let userNote = json[UserNoteKeys.userNote] as? String, let txHash = json[UserNoteKeys.txHash] as? String else {
            throw ICloud.ICloudError.restoringFromJsonError
        }
        
        self.userNote = userNote
        self.txHash = txHash
    }
    
}
