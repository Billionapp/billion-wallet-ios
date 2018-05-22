//
//  Strings+SearchContact.swift
//  BillionWallet
//
//  Created by Evolution Group Ltd on 16.02.2018.
//  Copyright © 2018 Evolution Group Ltd. All rights reserved.
//

import Foundation

extension Strings {
    enum SearchContact {
        static let contactNotFoud = NSLocalizedString("SearchContact.Notice.notFound", tableName: "SearchContact", value: "Contact not found", comment: "Label shown that after searching app can't find contact")
        static let searchFailed = NSLocalizedString("SearchContact.Notice.failed", tableName: "SearchContact", value: "Search failed", comment: "Search failed title")
        static let titleAddContact = NSLocalizedString("SearchContact.titleAddContact", tableName: "SearchContact", value: "Add contact", comment: "Add contact title")
        static let subtitleSearchMode = NSLocalizedString("SearchContact.subtitleSearchMode", tableName: "SearchContact", value: "Searching Billion users nearby", comment: "Searching Billion users nearby title")
    }
}
