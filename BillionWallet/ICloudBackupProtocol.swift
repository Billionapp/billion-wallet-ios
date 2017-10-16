//
//  ICloudBackupProtocol.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 06/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

protocol ICloudBackupProtocol {
    static var folder: String? { get }  // Documents folder if nil
    static var onlyLocal: Bool { get }
    
    var destination: String { get }
    var backupJson: [String: Any] { get }
    var attach: ICloudAttach? { get }
    
    init(from json: [String: Any], with attachData: Data?) throws
}

extension ICloudBackupProtocol {
    
    var attach: ICloudAttach? {
        return nil
    }
    
    static var onlyLocal: Bool {
        return false
    }
    
    var jsonWithAttachPreffix: [String: Any] {
        guard let attach = attach else {
            return backupJson
        }
        
        let attachPreffix = [
            "attach": [
                "file_name": attach.fileName,
                "type": attach.type
            ]
        ]
        
        return backupJson.merged(with: attachPreffix)
    }
    
    static var folderWithAccount: String {
        return "acc0/\(folder ?? "")"
    }
    
}

