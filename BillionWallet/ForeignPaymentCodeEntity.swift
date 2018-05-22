//
//  ForeignPaymentCodeEntity.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CoreData

@objc(ForeignPaymentCodeEntity)
public class ForeignPaymentCodeEntity: NSManagedObject {
                
    // MARK: - ContactProtocol
    @NSManaged public var displayName: String
    @NSManaged public var avatarData: Data?
    @NSManaged public var isArchived: Bool
    @NSManaged var txHashes: Set<String>
    @NSManaged public var lastUsed: NSNumber
    
    // MARK: - PaymentCodeContactProtocol
    @NSManaged var paymentCode: String
    @NSManaged var firstUnusedIndex: NSNumber
    @NSManaged var receiveAddresses: [String]
    @NSManaged var notificationTxHash: String?
    @NSManaged var incomingNotificationTxHash: String?
    @NSManaged var sendAddresses: [String]
    @NSManaged var notificationAddress: String
}
