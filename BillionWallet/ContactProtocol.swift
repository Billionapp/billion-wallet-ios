//
//  ContactProtocol.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

let defaultDisplayName = "Unnamed"

protocol ContactProtocol {
    static var uniqueAttribute: String { get }

    var uniqueValue: String { get }
    var displayName: String { get set}
    var avatarData: Data? { get set}
    var isArchived: Bool { get set }
    var txHashes: Set<String> { get set }
    
    var description: (smart: String, full: String) { get }
    var isNotificationTxNeededToSend: Bool { get }
    
    static func create(unique: String) -> Self
    func save()
    func isContact(for transaction: BRTransaction) -> Bool
    mutating func addressToSend() -> String?
}

// MARK: - Utillitys

extension ContactProtocol {
        
    var isAvatarSet: Bool {
        return avatarData != nil
    }
    
    var avatarImage: UIImage {
        if let avatarData = avatarData, let avatarImage = UIImage(data: avatarData) {
            return avatarImage
        }
        return createAvatarImage()
    }
    
}
