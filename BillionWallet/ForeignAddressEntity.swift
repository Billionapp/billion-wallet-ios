//
//  ForeignAddressEntity.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CoreData

@objc(ForeignAddressEntity)
public class ForeignAddressEntity: NSManagedObject {
    
    @NSManaged var address: String
    
    // MARK: - ContactProtocol
    @NSManaged var displayName: String
    @NSManaged var avatarData: Data?
    @NSManaged var isArchived: Bool
    @NSManaged var txHashes: Set<String>
    @NSManaged var lastUsed: NSNumber
}
