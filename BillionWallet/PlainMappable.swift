//
//  PlainMappable.swift
//  CoreDataTest
//
//  Created by Evolution Group Ltd on 02/10/2017.
//  Copyright © 2017 Evolution Group Ltd. All rights reserved.
//

import CoreData

protocol PlainMappable {
    associatedtype CoreDataObject: NSManagedObject
    
    static func map(from object: CoreDataObject) -> Self
}

