//
//  Strings+ContactCard.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum ContactCard {
        /* Modal */
        static let deleteLabel = NSLocalizedString("ContactCard.deleteLabel", tableName: "ContactCard", value: "Delete contact %@?", comment: "Label mean that you can delete contact you choose")
        
        /* Contact */
        static let namePlaceholder = NSLocalizedString("ContactCard.namePlaceholder", tableName: "ContactCard", value: "Your alias or name", comment: "Label shown alies or name")
    }
}
