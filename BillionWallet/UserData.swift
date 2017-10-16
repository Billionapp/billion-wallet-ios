//
//  UserData.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 21/09/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

struct UserData {
    
    let pc: String
    var name: String?
    var nickName: String?
    var avatarData: Data?
    
    init?(json: JSON) {
        guard let pc = json["pc"].string else {
            return nil
        }
        
        self.pc = pc
        
        if let name = json["name"].string {
            self.name = name
        }
        
        if let nickName = json["nick"].string {
            self.nickName = nickName
        }
        
        if let avatar = json["avatar"].string {
            self.avatarData = Data(base64Encoded: avatar)
        }
    }
    
    enum UserDataError: Error {
        case parsingError
    }
    
}
