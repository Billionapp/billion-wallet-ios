//
//  LocalUserData.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 15/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct LocalUserData {
    var name: String?
    var imageData: Data?
}

// MARK: - ICloudBackupProtocol

extension LocalUserData: ICloudBackupProtocol {
    
    static var folder: String? {
        return "UserData"
    }
    
    static var onlyLocal: Bool {
        return true
    }
    
    var destination: String {
        return "user_data"
    }
    
    var backupJson: [String: Any] {
        let json: [String: Any?] = ["name": name]
        return json.removeNils()
    }
    
    var attach: ICloudAttach? {
        guard let imageData = imageData else {
            return nil
        }
        
        return ICloudAttach.image(data: imageData)
    }
    
    init(from json: [String: Any], with attachData: Data?) throws {
        if let name = json["name"] as? String {
            self.name = name
        }
        self.imageData = attachData
    }
    
}
