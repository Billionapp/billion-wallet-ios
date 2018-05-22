//
//  ContactProtocol.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import Foundation

let defaultDisplayName = "Billionaire-"

protocol ContactProtocol: ContactDisplayable {
    static var uniqueAttribute: String { get }

    var uniqueValue: String { get }
    var displayName: String { get set }
    var avatarData: Data? { get set }
    var isArchived: Bool { get set }
    var txHashes: Set<String> { get set }
    var lastUsed: NSNumber { get set }
    
    var isNotificationTxNeededToSend: Bool { get }
    
    static func create(unique: String) -> Self
    func save()
    func backup(using icloud: ICloud) throws
    func getConnectedAddress(for transaction: Transaction) -> String?
    func addressToSend() -> String?
    func getSendAddresses() -> [String]
    func getNotificationAddress() -> String?
    var notificationTxHash: String? {get set}
    func getReceiveAddresses() -> [String]
    mutating func incrementFirstUnusedIndex()
    mutating func generateSendAddresses()
}


// MARK: - Utilities

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
    
    var qrImage: UIImage? {
        return createQRFromString(uniqueValue, size: CGSize(width: 150, height: 150), inverseColor: true)
    }
    
    func isContact(for transaction: Transaction) -> Bool {
        return getConnectedAddress(for: transaction) != nil
    }
    
}
