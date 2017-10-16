//
//  ForeignFriendEntity.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 03/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import UIKit

@objc(ForeignFriendEntity)
public class ForeignFriendEntity: NSManagedObject {
    
    @NSManaged var nickname: String?
    
    // MARK: - ContactProtocol
    @NSManaged var displayName: String
    @NSManaged var avatarData: Data?
    @NSManaged var isArchived: Bool
    @NSManaged var txHashes: Set<String>
    
    // MARK: - PaymentCodeContactProtocol
    @NSManaged var paymentCode: String
    @NSManaged var firstUnusedIndex: NSNumber
    @NSManaged var receiveAddresses: [String]
    @NSManaged var notificationTxHash: String?
    
}
