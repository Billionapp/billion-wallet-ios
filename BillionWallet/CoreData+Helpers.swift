//
//  CoreData+Helpers.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CoreData

enum CoreDataError: Error {
    case objectExists
}

extension NSManagedObject {
    
    static func all<PlainModel: ContactProtocol>() -> [PlainModel] where PlainModel: PlainMappable {
        let entities = allObjects() as! [PlainModel.CoreDataObject]
        return  entities.map { PlainModel.map(from: $0) }
    }
    
    static func find<Contact: ContactProtocol>(attribute: String, value: String) -> Contact? where Contact: PlainMappable {
        let args: [CVarArg] = [value as CVarArg]
        guard let entity = Contact.CoreDataObject.objects(matching:  "\(attribute) == %@", arguments: getVaList(args)).first as? Contact.CoreDataObject else {
            return nil
        }
        return Contact.map(from: entity)
    }
    
    static func findObject(attribute: String, value: String) -> NSManagedObject? {
        let args: [CVarArg] = [value as CVarArg]
        return objects(matching:  "\(attribute) == %@", arguments: getVaList(args)).first as? NSManagedObject
    }
    
    static func save() throws {
        do {
            try context().save()
        } catch {
            switch (error as NSError).code {
            case 133021:
                throw CoreDataError.objectExists
            default:
                throw error
            }
        }
    }
    
}
