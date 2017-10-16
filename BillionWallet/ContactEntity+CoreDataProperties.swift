//
//  ContactEntity+CoreDataProperties.swift
//  WalletUI
//
//  Created by Даниил Мирошниченко on 29.08.17.
//  Copyright © 2017 AquaMan. All rights reserved.
//

import Foundation
import CoreData


extension ContactEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContactEntity> {
        return NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
    }

    @NSManaged public var avatarData: NSData?
    @NSManaged public var displayName: String?
    @NSManaged public var isAvatarSet: NSNumber?
    @NSManaged public var typeString: String?
    @NSManaged public var alias: String?
    @NSManaged public var toMetaData: NSMutableSet?

}

// MARK: Generated accessors for toMetaData
extension ContactEntity {

    @objc(addToMetaDataObject:)
    @NSManaged public func addToToMetaData(_ value: BRTxMetadataEntity)

    @objc(removeToMetaDataObject:)
    @NSManaged public func removeFromToMetaData(_ value: BRTxMetadataEntity)

    @objc(addToMetaData:)
    @NSManaged public func addToToMetaData(_ values: NSSet)

    @objc(removeToMetaData:)
    @NSManaged public func removeFromToMetaData(_ values: NSSet)

}
