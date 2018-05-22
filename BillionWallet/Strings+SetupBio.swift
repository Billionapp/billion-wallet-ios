//
//  Strings+SetupBio.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 04/03/2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum SetupBio {
        static let title = NSLocalizedString("SetupBio.title", tableName: "SetupBio", value: "Touch ID", comment: "Touch ID title")
        static let titleTen = NSLocalizedString("SetupBio.titleTen", tableName: "SetupBio", value: "Face ID", comment: "Face ID title")
        static let faceIdSwitchTitle = NSLocalizedString("SetupBio.switchTitleTen", tableName: "SetupBio", value: "Enable Face ID", comment: "Face ID switch title")
        static let touchIdSwitchTitle = NSLocalizedString("SetupBio.switchTitle", tableName: "SetupBio", value: "Enable Touch ID", comment: "Touch ID switch title")
        static let next = NSLocalizedString("SetupBio.nextButton", tableName: "SetupBio", value: "Next", comment: "Next button title")
    }
}
